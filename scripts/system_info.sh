#!/usr/bin/env bash

set -uo pipefail

export LC_ALL=C

usage() {
    cat <<'EOF'
Usage: scripts/system_info.sh [--stdout] [--output PATH] [--force]

Collect reproducible Raspberry Pi system information.

Options:
  --stdout       Print the report instead of writing a file.
  --output PATH  Write to PATH instead of results/system_info.txt.
  --force        Replace an existing output file.
  -h, --help     Show this help.
EOF
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd -- "${script_dir}/.." && pwd)"
output_path="${project_root}/results/system_info.txt"
write_stdout=0
force=0

while (($# > 0)); do
    case "$1" in
        --stdout)
            write_stdout=1
            ;;
        --output)
            if (($# < 2)); then
                printf 'error: --output requires a path\n' >&2
                exit 2
            fi
            output_path="$2"
            shift
            ;;
        --force)
            force=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'error: unknown argument: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

warnings=0
errors=0

warn() {
    printf 'warning: %s\n' "$*" >&2
    ((warnings += 1))
}

error() {
    printf 'error: %s\n' "$*" >&2
    ((errors += 1))
}

require_command() {
    local command_name="$1"
    if ! command -v "$command_name" >/dev/null 2>&1; then
        error "required command not found: ${command_name}"
        return 1
    fi
}

read_value() {
    local path="$1"
    local required="${2:-optional}"

    if [[ -r "$path" ]]; then
        tr -d '\n' < "$path"
        return 0
    fi

    printf 'not_available'
    if [[ "$required" == "required" ]]; then
        error "required file is not readable: ${path}"
    else
        warn "optional file is not readable: ${path}"
    fi
    return 1
}

first_line() {
    local command_name="$1"
    shift
    local value

    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'not_available'
        error "required command not found: ${command_name}"
        return 1
    fi

    if ! value="$("$command_name" "$@" 2>&1)"; then
        printf 'command_failed'
        error "command failed: ${command_name} $*"
        return 1
    fi

    printf '%s' "${value%%$'\n'*}"
}

lscpu_field() {
    local field="$1"
    lscpu | awk -F: -v wanted="$field" '
        $1 == wanted {
            sub(/^[[:space:]]+/, "", $2)
            print $2
            exit
        }
    '
}

collect_report() {
    local required_commands=(date hostname uname lscpu awk grep tr getconf gcc g++ make cmake gdb git python3 perf objdump)
    local command_name
    for command_name in "${required_commands[@]}"; do
        require_command "$command_name" || true
    done

    printf '# Raspberry Pi Systems & Performance Lab\n'
    printf '# System information report\n\n'

    printf '[capture]\n'
    printf 'captured_at='; first_line date -Iseconds; printf '\n'
    printf 'hostname='; first_line hostname; printf '\n'
    printf 'collector=scripts/system_info.sh\n\n'

    printf '[operating_system]\n'
    if [[ -r /etc/os-release ]]; then
        awk -F= '
            $1 == "PRETTY_NAME" || $1 == "VERSION_CODENAME" {
                value = substr($0, index($0, "=") + 1)
                gsub(/^"|"$/, "", value)
                printf "%s=%s\n", tolower($1), value
            }
        ' /etc/os-release
    else
        error 'required file is not readable: /etc/os-release'
        printf 'pretty_name=not_available\nversion_codename=not_available\n'
    fi
    printf 'kernel_release='; first_line uname -r; printf '\n'
    printf 'kernel_machine='; first_line uname -m; printf '\n\n'

    printf '[cpu]\n'
    printf 'architecture=%s\n' "$(lscpu_field 'Architecture')"
    printf 'model_name=%s\n' "$(lscpu_field 'Model name')"
    printf 'online_cores='; first_line getconf _NPROCESSORS_ONLN; printf '\n'
    printf 'byte_order=%s\n' "$(lscpu_field 'Byte Order')"
    if [[ -r /proc/cpuinfo ]]; then
        printf 'isa_features='
        awk -F: '/^Features[[:space:]]*:/ {
            sub(/^[[:space:]]+/, "", $2)
            print $2
            exit
        }' /proc/cpuinfo
    else
        error 'required file is not readable: /proc/cpuinfo'
        printf 'isa_features=not_available\n'
    fi
    printf '\n'

    printf '[cpu_frequency]\n'
    local cpu_dirs=(/sys/devices/system/cpu/cpu[0-9]*)
    local cpu_dir cpu_name frequency_file
    local frequency_files=(scaling_governor scaling_cur_freq scaling_min_freq scaling_max_freq)
    if [[ ! -d "${cpu_dirs[0]}" ]]; then
        error 'no CPU directories found under /sys/devices/system/cpu'
    else
        for cpu_dir in "${cpu_dirs[@]}"; do
            cpu_name="${cpu_dir##*/}"
            for frequency_file in "${frequency_files[@]}"; do
                printf '%s.%s=' "$cpu_name" "$frequency_file"
                read_value "${cpu_dir}/cpufreq/${frequency_file}" optional || true
                printf '\n'
            done
        done
    fi
    printf '\n'

    printf '[cache]\n'
    local cache_dirs=(/sys/devices/system/cpu/cpu0/cache/index*)
    local cache_dir cache_name cache_field
    local cache_fields=(level type size coherency_line_size ways_of_associativity shared_cpu_list)
    if [[ ! -d "${cache_dirs[0]}" ]]; then
        error 'no cache directories found under /sys/devices/system/cpu/cpu0/cache'
    else
        for cache_dir in "${cache_dirs[@]}"; do
            cache_name="${cache_dir##*/}"
            for cache_field in "${cache_fields[@]}"; do
                printf '%s.%s=' "$cache_name" "$cache_field"
                read_value "${cache_dir}/${cache_field}" optional || true
                printf '\n'
            done
        done
    fi
    printf '\n'

    printf '[memory]\n'
    if [[ -r /proc/meminfo ]]; then
        grep -E '^(MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree):' /proc/meminfo
    else
        error 'required file is not readable: /proc/meminfo'
        printf 'memory_info=not_available\n'
    fi
    printf '\n'

    printf '[thermal]\n'
    local thermal_dirs=(/sys/class/thermal/thermal_zone*)
    local thermal_dir thermal_name raw_temp
    if [[ ! -d "${thermal_dirs[0]}" ]]; then
        error 'no thermal zones found under /sys/class/thermal'
    else
        for thermal_dir in "${thermal_dirs[@]}"; do
            thermal_name="${thermal_dir##*/}"
            printf '%s.type=' "$thermal_name"
            read_value "${thermal_dir}/type" optional || true
            printf '\n'
            printf '%s.temp_millicelsius=' "$thermal_name"
            if [[ -r "${thermal_dir}/temp" ]]; then
                raw_temp="$(tr -d '\n' < "${thermal_dir}/temp")"
                printf '%s\n' "$raw_temp"
                if [[ "$raw_temp" =~ ^-?[0-9]+$ ]]; then
                    awk -v name="$thermal_name" -v value="$raw_temp" \
                        'BEGIN { printf "%s.temp_celsius=%.1f\n", name, value / 1000 }'
                else
                    warn "non-numeric temperature: ${thermal_dir}/temp"
                    printf '%s.temp_celsius=not_available\n' "$thermal_name"
                fi
            else
                printf 'not_available\n'
                warn "optional file is not readable: ${thermal_dir}/temp"
            fi
        done
    fi
    printf '\n'

    printf '[runtime]\n'
    if [[ -r /proc/uptime ]]; then
        local uptime_seconds idle_seconds_total
        read -r uptime_seconds idle_seconds_total < /proc/uptime
        printf 'uptime_seconds=%s\n' "$uptime_seconds"
        printf 'idle_seconds_total=%s\n' "$idle_seconds_total"
    else
        error 'required file is not readable: /proc/uptime'
        printf 'uptime_seconds=not_available\n'
        printf 'idle_seconds_total=not_available\n'
    fi
    printf 'load_average='; read_value /proc/loadavg required || true; printf '\n\n'

    printf '[toolchain]\n'
    printf 'gcc='; first_line gcc --version; printf '\n'
    printf 'g++='; first_line g++ --version; printf '\n'
    printf 'make='; first_line make --version; printf '\n'
    printf 'cmake='; first_line cmake --version; printf '\n'
    printf 'gdb='; first_line gdb --version; printf '\n'
    printf 'git='; first_line git --version; printf '\n'
    printf 'python='; first_line python3 --version; printf '\n'
    printf 'perf='; first_line perf --version; printf '\n'
    printf 'objdump='; first_line objdump --version; printf '\n\n'

    printf '[collection]\n'
    printf 'warnings=%d\n' "$warnings"
    printf 'errors=%d\n' "$errors"
    if ((errors == 0)); then
        printf 'status=ok\n'
        return 0
    fi

    printf 'status=failed\n'
    return 1
}

if ((write_stdout == 1)); then
    collect_report
    exit $?
fi

output_dir="$(dirname -- "$output_path")"
if ! mkdir -p -- "$output_dir"; then
    printf 'error: cannot create output directory: %s\n' "$output_dir" >&2
    exit 1
fi

if [[ -e "$output_path" && "$force" -ne 1 ]]; then
    printf 'error: output already exists: %s\n' "$output_path" >&2
    printf 'hint: use --force or --output PATH\n' >&2
    exit 2
fi

temporary_output="$(mktemp "${output_path}.tmp.XXXXXX")" || {
    printf 'error: cannot create temporary output beside %s\n' "$output_path" >&2
    exit 1
}
trap 'rm -f -- "$temporary_output"' EXIT

collection_status=0
collect_report > "$temporary_output" || collection_status=$?

if ! mv -- "$temporary_output" "$output_path"; then
    printf 'error: cannot move report into place: %s\n' "$output_path" >&2
    exit 1
fi
trap - EXIT

printf 'wrote %s\n' "$output_path"
exit "$collection_status"
