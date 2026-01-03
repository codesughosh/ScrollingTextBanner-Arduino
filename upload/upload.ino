extern "C" void asm_main(void);

void setup() {
  asm_main();   // transfer control to AVR assembly
}

void loop() {
  // never used
}
