int AnalogPin0 = A0; //Declare an integer variable, hooked up to analog pin 0

int AnalogPin1 = A1; //Declare an integer variable, hooked up to analog pin 1

//int AnalogPin2 = A2; //Declare an integer variable, hooked up to analog pin 2

int DigitalPin1 = 2;

 

void setup() {

  Serial.begin(9600); // Begin Serial Communication with a baud rate of 9600

  pinMode(DigitalPin1, INPUT);

  digitalWrite(DigitalPin1, HIGH);   // turn on the internal pull-up resistor

}

 

void loop() {

  // New variables are declared to store the readings of the respective pins

  int Value1 = analogRead(AnalogPin0);

  int Value2 = analogRead(AnalogPin1);

//  int Value3 = analogRead(AnalogPin2);

  int Value4 = digitalRead(DigitalPin1);

 

  /*The Serial.print() function does not execute a "return" or a space

   * Also, the "," character is essential for parsing the values,

   * The comma is not necessary after the last variable.

   */

 

  Serial.print(Value1, DEC);

  Serial.print(",");

  Serial.print(Value2, DEC);

  Serial.print(",");

//  Serial.print(Value3, DEC);

//  Serial.println(",");
  
  Serial.print(Value4, DEC);

  Serial.println();

  delay(16);

}
