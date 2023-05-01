#include <stdint.h>
#include <stdio.h>
#include "esp_err.h"
#include "esp32/ulp.h"
#include "esp_http_client.h"
#include "esp_wifi.h"
#include "hal/gpio_types.h"
#include "hal/rtc_io_types.h"
#include "soc/rtc_cntl_reg.h"
#include "soc/sens_reg.h"
#include "ulp_common.h"
#include "ulp_main.h"
#include "driver/gpio.h"
#include "driver/rtc_io.h"
#include "esp_sleep.h"
#include "esp_log.h"

#define GPIO_SDA    GPIO_NUM_27
#define GPIO_SCL    GPIO_NUM_25

extern const uint8_t ulp_main_bin_start[] asm("_binary_ulp_main_bin_start");
extern const uint8_t ulp_main_bin_end[]   asm("_binary_ulp_main_bin_end");

void rtc_initialization ( void );

void app_main ( void ) {
    esp_sleep_wakeup_cause_t cause = esp_sleep_get_wakeup_cause();
    if (cause != ESP_SLEEP_WAKEUP_ULP) {
      ulp_load_binary(0, ulp_main_bin_start, (ulp_main_bin_end - ulp_main_bin_start) / sizeof(uint32_t));
    } else {
        printf("ULP start");
    }
    rtc_initialization();

    ulp_run(&ulp_entry - RTC_SLOW_MEM);
    esp_sleep_enable_ulp_wakeup();
    esp_deep_sleep_start();
}

void rtc_initialization ( void ) {
    rtc_gpio_init(GPIO_SDA);
	rtc_gpio_pullup_en(GPIO_SDA);
	rtc_gpio_set_direction(GPIO_SDA, RTC_GPIO_MODE_INPUT_OUTPUT_OD);
    rtc_gpio_init(GPIO_SCL);
	rtc_gpio_pullup_en(GPIO_SCL);
	rtc_gpio_set_direction(GPIO_SCL, RTC_GPIO_MODE_INPUT_OUTPUT_OD);
    rtc_gpio_init(GPIO_NUM_27);
    rtc_gpio_pulldown_en(GPIO_NUM_27);
    rtc_gpio_set_direction(GPIO_NUM_27, RTC_GPIO_MODE_INPUT_ONLY);
}

