#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/spi/spidev.h>

static const char *device = "/dev/spidev0.0";
static uint8_t mode = 0;
static uint8_t bits = 8;
static uint32_t speed = 400000;

static void pabort(const char *s)
{
    perror(s);
    abort();
}

// 0-9, A-F的7段编码 (共阳极)
static unsigned char seg_code[16] = {
    0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07,
    0x7f, 0x6f, 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71
};

int main(int argc, char *argv[])
{
    if(argc != 2) {
        printf("Usage: %s <4-digit-hex>\n", argv[0]);
        return -1;
    }

    unsigned int display_num;
    if(sscanf(argv[1], "%04x", &display_num) != 1) {
        printf("Error: Invalid argument. Use 4-digit hex number.\n");
        return -1;
    }

    int fd = open(device, O_RDWR);
    if (fd < 0)
        pabort("can't open device");

    // SPI配置
    if (ioctl(fd, SPI_IOC_WR_MODE, &mode) == -1)
        pabort("can't set spi mode");
    if (ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &bits) == -1)
        pabort("can't set bits per word");
    if (ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed) == -1)
        pabort("can't set max speed hz");

    printf("SPI mode: %d\n", mode);
    printf("Bits per word: %d\n", bits);
    printf("Max speed: %d Hz\n", speed);
    printf("Displaying: %04X\n", display_num);

    unsigned char buf[2];
    int i;
    
	int t = 600;
    // 动态扫描显示
    while(t--) {
        for(i = 0; i < 4; i++) {
            buf[0] = (1 << i);  // 位选 - 选择第i个数码管
            // 获取对应位的数字编码
            buf[1] = seg_code[(display_num >> ((3-i)*4)) & 0x0F];
            
            if (write(fd, buf, 2) < 0)
                perror("SPI write error");
            
            usleep(1000);  // 缩短延时提高刷新率
        }
    }
	//把所有数码管关闭
    buf[0] = 0x00;
    buf[1] = 0x00;
    if (write(fd, buf, 2) < 0)
        perror("SPI write error");
    close(fd);
    return 0;
}