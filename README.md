# ESP32 ULP I2C

## Description
I2C communication for the ESP32 ULP-coprocessor written in assembly language.

Here is an example of how to use the ULP coprocessor to exchange data with external devices using I2C communication. There are two functions in the **i2c_label.S** file which can be used by the macros **order_write** and **order_read** to build labels.

```asm
  .set    ADDRESS_W_COM,  0x80
  .set    ACK_COM,        0x01
  .set    START_COM,      0x01
  .set    NO_STOP_COM,    0x00

  order_write     START_COM       ADDRESS_W_COM   ACK_COM     NO_STOP_COM
  psr
  jump    i2c_write
```

![I2C write](files/i2c_write.svg)
![I2C read](files/i2c_read.svg)
