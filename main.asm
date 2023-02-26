/********************************************************************************
* main.asm: Demonstration av arrayer i assembler. Vi skriver samtliga bin�ra 
*           kombinationer 0000 - 1111 (0 - 15) till dataregister PORTB (adress
*           0x25). Dessa bin�ra kombinationer lagras i en statisk array,
*           vars startadress lagras p� RAMEND (0x0900).
********************************************************************************/
.EQU RESET_vect = 0x00 ; Reset-vektor, utg�r programmets startpunkt.

/********************************************************************************
* .CSEG: Kodsegemtet, h�r lagras programkoden.
********************************************************************************/
.CSEG

/********************************************************************************
* RESET_vect: Programmets startpunkt. Programhopp sker till subrutinen main
*             f�r att k�ra programmet.
********************************************************************************/
.ORG RESET_vect
   RJMP main        ; K�r programmet.

/********************************************************************************
* assign: Fyller array av angiven storlek till bredden med heltal. Startv�rde
*         samt stegv�rde kan v�ljas godtyckligt.
*
*         - R25:R24: Referens till arrayen (pekar p� f�rsta elementet).
*         - R22    : Arrayens storlek, dvs. antalet element den rymmer.
*         - R20    : Startv�rdet, dvs. det element som l�ggs till f�rst.
*         - R18    : Stegv�rdet, indikerar differensen mellan varje element.
********************************************************************************/
assign:
   MOVW Z, R24      ; Kopierar arrayens adress till Z-registret f�r skrivning.
   LDI R16, 0x00    ; Anv�nder R16 som en loopr�knare.
assign_loop:
   CP R16, R22      ; Har vi itererat genom hela arrayen?
   BREQ assign_end  ; Om detta �r fallet avslutas loopen. 
   ST Z+, R20       ; Skriver aktuellt tal till arrayen och itererar till n�sta element.
   ADD R20, R18     ; �kar talet vi l�gger till med stegv�rdet inf�r n�sta skrivning.
   INC R16          ; R�knar upp antalet varv som har k�rts.
   RJMP assign_loop ; K�r sedan om loopen (tills arrayen har fyllts till max).
assign_end:
   RET              ; Avslutar subrutinen n�r arrayen har fyllts till bredden.

/********************************************************************************
* write: Skriver samtliga element lagrade i refererad array en efter en till
*        refererat destinationsregister.
*
*        - R25:R24: Referens till arrayen (pekar p� f�rsta elementet).
*        - R22    : Arrayens storlek, dvs. antalet element den rymmer.
*        - R21:R20: Referens till destinationsregistret.
********************************************************************************/
write:
   MOVW Z, R24      ; Kopierar arrayens adress till Z-registret f�r l�sning.
   MOVW X, R20      ; Kopierar destinationsadressen till X-register f�r skrivning.
   LDI R16, 0x00    ; Anv�nder R16 som en loopr�knare.
write_loop:
   CP R16, R22      ; Har vi itererat genom hela arrayen?
   BREQ write_end   ; Om detta �r fallet avslutas loopen.
   LD R24, Z+       ; H�mtar elementet fr�n arrayen och itererar till n�sta element.
   ST X, R24        ; Skriver det h�mtade elementet till destinationsadressen.
   INC R16          ; R�knar upp antalet varv som har k�rts.
   RJMP write_loop  ; K�r sedan om loopen (tills alla element i arrayen har h�mtats).
write_end:
   RET              ; Avslutar subrutinen n�r skrivningen har slutf�rts.

/********************************************************************************
* main: Lagrar h�gsta adressen i SRAM (RAMEND = 0x08FF) i Y-registret.
*       Denna adress anv�nds ocks� f�r att initiera stackpekaren (tilldelas
*       till SPH samt SPL).
*
*       Deklarerar en statisk array som rymmer 16 8-bitars heltal. Sedan s�tts 
*       PORTB0-PORTB3 till utportar. Arrayen fylls till bredden med heltal
*       0 - 15. Arrayens samtliga element h�mtas en efter en och skrivs till 
*       PORTB en i taget.
********************************************************************************/
main:
   LDI YL, low(RAMEND)  ; Lagrar RAMEND[7:0] i YL (R28). 
   LDI YH, high(RAMEND) ; Lagrar RAMEND[15:8] i YH (R29). 
   OUT SPL, YL          ; Initierar stackpekaren (SPL = 0xFF).
   OUT SPH, YH          ; Initierar stackpekaren (SPH = 0x08).

   LDI R16, 0x0F        ; Lagrar 0000 1111 i R16 f�r skrivning till DDRB.
   OUT DDRB, R16        ; S�tter PORTB0 - PORTB3 till utportar.

   MOVW R24, Y          ; Kopierar �ver RAMEND-adressen fr�n Y till R24.
   ADIW R24, 1          ; Arrayens startadress s�tts till RAMEND + 1, lagras i R25:R24.
   LDI R22, 16          ; Laddar arrayens storlek i R22.
   LDI R20, 0           ; Laddar arrayens startv�rde i R20.
   LDI R18, 1           ; Laddar arrayens stegv�rde i R18.
   RCALL assign         ; Fyller arrayen till bredden via anrop av subrutinen assign.

   MOVW R24, Y          ; Kopierar �ver RAMEND-adressen fr�n Y till R24.
   ADIW R24, 1          ; Arrayens startadress s�tts till RAMEND + 1, lagras i R25:R24.
   LDI R22, 16          ; Laddar arrayens storlek i R22.
   LDI R20, 0x25        ; Laddar &PORTB[7:0] i R20.
   LDI R21, 0x00        ; Laddar &PORTB[15:0] i R20.
   RCALL write          ; Skriver arrayens samtliga element en i taget till PORTB.

/********************************************************************************
* end: Programmets slutadress. H�r stannar programmet.
********************************************************************************/
end:
   RJMP end             ; Genererar en tom loop.

