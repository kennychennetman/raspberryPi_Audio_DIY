#include <IRremote.h>
#include <IRremoteInt.h>

// initialize components and variables
int IR_PIN = 11;        // Read IR in
int BTN_PIN = 2;        // Read Button in
byte btnValue = LOW;
IRrecv irrecv(IR_PIN);
decode_results results;
const long StoredCode = 0x2307B446; //IR power code
const int rpiPin = 6;    // Rpi pin (OUT)
const int relayPin = 5;  // Relay pin (OUT)
int outputState = 0;
long lastBtnCheck = 0;
long lastgpioCheck = 0;
long BtncheckDelay = 3000;
long gpiocheckDelay = 2000;

void setup() 
{ 
  Serial.begin(9600);
  irrecv.enableIRIn();
  pinMode(rpiPin, OUTPUT);
  digitalWrite(rpiPin, LOW);
  pinMode(relayPin, OUTPUT);
  digitalWrite(relayPin, LOW);
  pinMode(BTN_PIN, INPUT);
}

void loop() 
{

  btnValue = digitalRead(BTN_PIN); // read button

  // start pi power on check
  if (outputState == 0) {
    if (irrecv.decode(&results)) { 
      if(StoredCode == (results.value)) {
        Serial.println("Infrared Signal recieved. Switching relay & RPI on.");
        digitalWrite(rpiPin, HIGH);
        digitalWrite(relayPin, HIGH);
        delay(10000);
        outputState = 1; 
      }
      irrecv.resume(); 
    } else {   
      if (btnValue == HIGH) {
        Serial.println("Button Signal recieved. Switching relay & RPI on.");
        digitalWrite(rpiPin, HIGH);
        digitalWrite(relayPin, HIGH);
        delay(10000);
        outputState = 1; 
      }
    }
  // end pi power on check
  
  } else {
  
  // start pi power off check

    if (btnValue == HIGH) {
      Serial.println("Button Signal recieved. Switching RPI off.");
      digitalWrite(rpiPin, LOW);
      delay(1000);
      if ( (millis() - lastBtnCheck) > BtncheckDelay )  // Button hold more than 3sec
      {
        Serial.println("Button hold, force to switching relay off.");
        digitalWrite(relayPin, LOW);
        delay(5000);
        outputState = 0;
      }
    } else {
      int gpioState = analogRead(A0);
      float voltage = gpioState * (5.0 / 1023.0);
      if (voltage < 3.10)
      {
        if ( (millis() - lastgpioCheck) > gpiocheckDelay ) // Only run after gpio LOW for 2sec
        {
          Serial.println("Raspberry Pi powered down. Switching relay off.");
          delay(6000);
          digitalWrite(relayPin, LOW);
          digitalWrite(rpiPin, LOW);
          outputState = 0;
        }
      } else {
        lastgpioCheck = millis();   // Reset gpio count
      }
      lastBtnCheck = millis();  // Reset button count
    }
  }
  
  // end pi power off check

}
