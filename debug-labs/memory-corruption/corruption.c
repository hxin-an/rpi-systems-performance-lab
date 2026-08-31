#include <stddef.h>
#include <stdio.h>

typedef struct {
    int samples[4];
    int status;
} SampleBuffer;

static void fill_samples(SampleBuffer *buffer)
{
    for (size_t index = 0; index <= 4; ++index) {
        buffer->samples[index] = 100 + (int)index;
    }
}

int main(void)
{
    SampleBuffer buffer = {
        .samples = {0, 0, 0, 0},
        .status = 1,
    };

    printf("before: status = %d\n", buffer.status);
    fill_samples(&buffer);
    printf("after:  status = %d\n", buffer.status);

    if (buffer.status != 1) {
        fprintf(stderr, "memory corruption detected\n");
        return 1;
    }

    return 0;
}
