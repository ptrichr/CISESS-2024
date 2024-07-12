const int pwmPin = 9;
const int highPWM = 102;
const int lowPWM = 0;
const int delayTime = 500; // Delay time in milliseconds (controls the frequency)

void setup() {
  pinMode(pwmPin, OUTPUT);
}

void loop() {
  // Generate square wave
  analogWrite(pwmPin, highPWM); // Set pin to 2V
  delay(delayTime); // Wait for half period
  analogWrite(pwmPin, lowPWM); // Set pin to 0V
  delay(delayTime); // Wait for half period
}
