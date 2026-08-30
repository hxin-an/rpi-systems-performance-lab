#include <stddef.h>
#include <stdio.h>
#include <string.h>

typedef struct {
    const char *name;
    const int *samples;
    size_t sample_count;
} Sensor;

static const Sensor *find_sensor(const Sensor *sensors,
                                 size_t sensor_count,
                                 const char *requested_name)
{
    for (size_t index = 0; index < sensor_count; ++index) {
        if (strcmp(sensors[index].name, requested_name) == 0) {
            return &sensors[index];
        }
    }

    return NULL;
}

static int latest_sample(const Sensor *sensor)
{
    return sensor->samples[sensor->sample_count - 1];
}

static void print_sensor(const Sensor *sensor)
{
    int sample = latest_sample(sensor);
    printf("%s: latest sample = %d\n", sensor->name, sample);
}

static void process_request(const Sensor *sensors,
                            size_t sensor_count,
                            const char *requested_name)
{
    const Sensor *sensor = find_sensor(sensors, sensor_count, requested_name);
    print_sensor(sensor);
}

int main(int argc, char **argv)
{
    const int cpu_samples[] = {41, 42, 43};
    const int board_samples[] = {37, 38, 39};
    const Sensor sensors[] = {
        {.name = "cpu", .samples = cpu_samples, .sample_count = 3},
        {.name = "board", .samples = board_samples, .sample_count = 3},
    };
    const char *requested_name = argc > 1 ? argv[1] : "ambient";

    process_request(sensors,
                    sizeof(sensors) / sizeof(sensors[0]),
                    requested_name);
    return 0;
}
