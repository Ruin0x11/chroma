/* Ports and Pins
 
 Direct port access is much faster than digitalWrite.
 You must match the correct port and pin as shown in the table below.
 
 Arduino Pin        Port        Pin
 13 (SCK)           PORTB       5
 12 (MISO)          PORTB       4
 11 (MOSI)          PORTB       3
 10 (SS)            PORTB       2
 9                  PORTB       1
 8                  PORTB       0
 7                  PORTD       7
 6                  PORTD       6
 5                  PORTD       5
 4                  PORTD       4
 3                  PORTD       3
 2                  PORTD       2
 1 (TX)             PORTD       1
 0 (RX)             PORTD       0
 A5 (Analog)        PORTC       5
 A4 (Analog)        PORTC       4
 A3 (Analog)        PORTC       3
 A2 (Analog)        PORTC       2
 A1 (Analog)        PORTC       1
 A0 (Analog)        PORTC       0
 
 */

// Defines for use with Arduino functions
#define clockpin   13 // CL
#define enablepin  10 // BL
#define latchpin    9 // XL
#define datapin    11 // SI

// Defines for direct port access
#define CLKPORT PORTB
#define ENAPORT PORTB
#define LATPORT PORTB
#define DATPORT PORTB
#define CLKPIN  5
#define ENAPIN  2
#define LATPIN  1
#define DATPIN  3

// Variables for communication
unsigned long SB_CommandPacket;
int SB_CommandMode;
int SB_BlueCommand;
int SB_RedCommand;
int SB_GreenCommand;

// Define number of OctoBrite modules
#define NumOctoBrites 1
// Create LED value storage array
uint16_t LEDChannels[NumOctoBrites*8][3] = {0};
int gammatable[]={0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,2,2,2,2,2,3,3,3,4,4,4,5,5,6,6,6,7,7,8,8,9,10,10,11,12,12,13,14,14,15,16,17,18,19,19,20,21,22,23,24,26,27,28,29,30,31,33,34,35,36,38,39,41,42,44,45,47,48,50,52,53,55,57,58,60,62,64,66,68,70,72,74,76,78,80,82,85,87,89,92,94,96,99,101,104,106,109,112,114,117,120,123,125,128,131,134,137,140,143,146,149,153,156,159,162,166,169,172,176,179,183,187,190,194,198,201,205,209,213,217,221,225,229,233,237,241,246,250,254,258,263,267,272,276,281,286,290,295,300,305,310,314,319,324,329,335,340,345,350,355,361,366,372,377,383,388,394,400,405,411,417,423,429,435,441,447,453,459,465,472,478,484,491,497,504,510,517,524,530,537,544,551,558,565,572,579,586,593,601,608,615,623,630,638,645,653,661,668,676,684,692,700,708,716,724,732,740,749,757,765,774,782,791,800,808,817,826,835,844,853,862,871,880,889,898,908,917,926,936,945,955,965,974,984,994,1004,1014,1023};

// Set pins to outputs and initial states
void setup() {
  pinMode(datapin, OUTPUT);
  pinMode(latchpin, OUTPUT);
  pinMode(enablepin, OUTPUT);
  pinMode(clockpin, OUTPUT);
  digitalWrite(latchpin, LOW);
  digitalWrite(enablepin, LOW);
  SPCR = (1<<SPE)|(1<<MSTR)|(0<<SPR1)|(0<<SPR0);
  
  Serial.begin(115200);
  
}

// Load values into SPI register
void SB_SendPacket() {
 
    if (SB_CommandMode == B01) {
     SB_RedCommand = 127;
     SB_GreenCommand = 127;
     SB_BlueCommand = 127;
    }
 
    SPDR = SB_CommandMode << 6 | SB_BlueCommand>>4;
    while(!(SPSR & (1<<SPIF)));
    SPDR = SB_BlueCommand<<4 | SB_RedCommand>>6;
    while(!(SPSR & (1<<SPIF)));
    SPDR = SB_RedCommand << 2 | SB_GreenCommand>>8;
    while(!(SPSR & (1<<SPIF)));
    SPDR = SB_GreenCommand;
    while(!(SPSR & (1<<SPIF)));
 
}

// Latch values into PWM registers
void SB_Latch() {

  delayMicroseconds(1);
  LATPORT += (1 << LATPIN);
  //ENAPORT += (1 << ENAPIN);
  //delayMicroseconds(10);
  //ENAPORT &= ~(1 << ENAPIN);
  LATPORT &= ~(1 << LATPIN);

}

// for octobrite
void WriteLEDArray() {

  unsigned int tempOne = 0;

  for (int i = 0; i < (NumOctoBrites * 24); i++) {

    tempOne = *(&LEDChannels[0][0] + i);

    for (int j = 0; j < 12; j++) {
      if ((tempOne >> (11 - j)) & 1) {
        DATPORT |= (1 << DATPIN);
      } 
      else {
        DATPORT &= ~(1 << DATPIN);
      }
      CLKPORT |= (1 << CLKPIN);
      CLKPORT &= ~(1 << CLKPIN); 
    } 

  }
  LATPORT |= (1 << LATPIN);
  LATPORT &= ~(1 << LATPIN);
}

int inIndex = 999;
byte inByte = 0;

void loop() {

  if (Serial.available() > 0) {

    inByte = Serial.read();

    if (inByte == 255) {

      inIndex = 0;

    } else {

      if (inIndex == 0) {
        if (inByte == 254) {
          WriteLEDArray();
          inByte = 0;
          inIndex = 999;
        } else if (inByte == 253) {
          //clearAll();
          inByte = 0;
          inIndex = 999;
        }
      } else if ((inIndex > 0) && (inIndex < (NumOctobrites*8*3+1))) {
        *(&LEDChannels[0][0] + (inIndex-1)) =  gammatable[inByte];
      }
        
      inIndex++;      
    }
      
  }
}
