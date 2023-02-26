/********************************************************************************
* main.c: Demonstration av arrayer i C f�r att j�mf�ra med motsvarande 
*         assemblerkod. Skriver samtliga bin�ra kombinationer 0000 - 1111 
*         (0 - 15) till dataregister PORTB. Dessa bin�ra kombinationer lagras 
*         i en statisk array. I detta fall anv�nds inga bibliotek, s� pekare
*         till DDRB (adress 0x24) samt PORTB (adress 0x25) implementeras.
********************************************************************************/
typedef unsigned char uint8_t; /* Realiserar uint8_t som ett alias. */

/********************************************************************************
* Pekare till I/O-register:
********************************************************************************/
static volatile uint8_t* const ddrb = (volatile uint8_t*)(0x24);
static volatile uint8_t* const portb = (volatile uint8_t*)(0x25);

/********************************************************************************
* Makron f�r skrivning/l�sning till/fr�n I/O-register:
********************************************************************************/
#define DDRB *ddrb  
#define PORTB *portb 

/********************************************************************************
* assign: Fyller array av angiven storlek till bredden med heltal. Startv�rde
*         samt stegv�rde kan v�ljas godtyckligt.
*
*         - data     : Referens till arrayen (pekar p� f�rsta elementet).
*         - size     : Arrayens storlek, dvs. antalet element den rymmer.
*         - start_val: Startv�rdet, dvs. det element som l�ggs till f�rst.
*         - step_val : Stegv�rdet, indikerar differensen mellan varje element.
********************************************************************************/
static inline void assign(uint8_t* data,
                          const uint8_t size,
                          const uint8_t start_val,
                          const uint8_t step_val)
{
   uint8_t val = start_val;

   for (uint8_t* i = data; i < data + size; ++i)
   {
      *i = val;
      val += step_val;
   }
   return;
}

/********************************************************************************
* write: Skriver samtliga element lagrade i refererad array en efter en till
*        refererat destinationsregister.
*
*        - data       : Referens till arrayen (pekar p� f�rsta elementet).
*        - size       : Arrayens storlek, dvs. antalet element den rymmer.
*        - destination: Referens till destinationsregistret.
********************************************************************************/
static inline void write(const uint8_t* data,
                         const uint8_t size,
                         volatile uint8_t* destination)
{
   for (const uint8_t* i = data; i < data + size; ++i)
   {
      *destination = *i;
   }
   return;
}

/********************************************************************************
* main: Deklarerar en statisk array som rymmer 16 8-bitars heltal. Sedan s�tts 
*       PORTB0-PORTB3 till utportar. Arrayen fylls till bredden med heltal
*       0 - 15. Arrayens samtliga element h�mtas en efter en och skrivs till 
*       PORTB en i taget.
********************************************************************************/
int main(void)
{
   uint8_t data[16];
   DDRB = 0x0F;

   assign(data, 16, 0, 1);
   write(data, 16, &PORTB);
   return 0;
}

