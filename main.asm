/********************************************************************************
* main.asm: Demonstration av arrayer i assembler. Vi skriver samtliga binära 
*           kombinationer 0000 - 1111 (0 - 15) till dataregister PORTB (adress
*           0x25). Dessa binära kombinationer lagras i en statisk array,
*           vars startadress lagras på RAMEND (0x0900).
********************************************************************************/
.EQU RESET_vect = 0x00 ; Reset-vektor, utgör programmets startpunkt.

/********************************************************************************
* .CSEG: Kodsegemtet, här lagras programkoden.
********************************************************************************/
.CSEG

/********************************************************************************
* RESET_vect: Programmets startpunkt. Programhopp sker till subrutinen main
*             för att köra programmet.
********************************************************************************/
.ORG RESET_vect
   RJMP main        ; Kör programmet.

/********************************************************************************
* assign: Fyller array av angiven storlek till bredden med heltal. Startvärde
*         samt stegvärde kan väljas godtyckligt.
*
*         - R25:R24: Referens till arrayen (pekar på första elementet).
*         - R22    : Arrayens storlek, dvs. antalet element den rymmer.
*         - R20    : Startvärdet, dvs. det element som läggs till först.
*         - R18    : Stegvärdet, indikerar differensen mellan varje element.
********************************************************************************/
assign:
   MOVW Z, R24      ; Kopierar arrayens adress till Z-registret för skrivning.
   LDI R16, 0x00    ; Använder R16 som en loopräknare.
assign_loop:
   CP R16, R22      ; Har vi itererat genom hela arrayen?
   BREQ assign_end  ; Om detta är fallet avslutas loopen. 
   ST Z+, R20       ; Skriver aktuellt tal till arrayen och itererar till nästa element.
   ADD R20, R18     ; Ökar talet vi lägger till med stegvärdet inför nästa skrivning.
   INC R16          ; Räknar upp antalet varv som har körts.
   RJMP assign_loop ; Kör sedan om loopen (tills arrayen har fyllts till max).
assign_end:
   RET              ; Avslutar subrutinen när arrayen har fyllts till bredden.

/********************************************************************************
* write: Skriver samtliga element lagrade i refererad array en efter en till
*        refererat destinationsregister.
*
*        - R25:R24: Referens till arrayen (pekar på första elementet).
*        - R22    : Arrayens storlek, dvs. antalet element den rymmer.
*        - R21:R20: Referens till destinationsregistret.
********************************************************************************/
write:
   MOVW Z, R24      ; Kopierar arrayens adress till Z-registret för läsning.
   MOVW X, R20      ; Kopierar destinationsadressen till X-register för skrivning.
   LDI R16, 0x00    ; Använder R16 som en loopräknare.
write_loop:
   CP R16, R22      ; Har vi itererat genom hela arrayen?
   BREQ write_end   ; Om detta är fallet avslutas loopen.
   LD R24, Z+       ; Hämtar elementet från arrayen och itererar till nästa element.
   ST X, R24        ; Skriver det hämtade elementet till destinationsadressen.
   INC R16          ; Räknar upp antalet varv som har körts.
   RJMP write_loop  ; Kör sedan om loopen (tills alla element i arrayen har hämtats).
write_end:
   RET              ; Avslutar subrutinen när skrivningen har slutförts.

/********************************************************************************
* main: Lagrar högsta adressen i SRAM (RAMEND = 0x08FF) i Y-registret.
*       Denna adress används också för att initiera stackpekaren (tilldelas
*       till SPH samt SPL).
*
*       Deklarerar en statisk array som rymmer 16 8-bitars heltal. Sedan sätts 
*       PORTB0-PORTB3 till utportar. Arrayen fylls till bredden med heltal
*       0 - 15. Arrayens samtliga element hämtas en efter en och skrivs till 
*       PORTB en i taget.
********************************************************************************/
main:
   LDI YL, low(RAMEND)  ; Lagrar RAMEND[7:0] i YL (R28). 
   LDI YH, high(RAMEND) ; Lagrar RAMEND[15:8] i YH (R29). 
   OUT SPL, YL          ; Initierar stackpekaren (SPL = 0xFF).
   OUT SPH, YH          ; Initierar stackpekaren (SPH = 0x08).

   LDI R16, 0x0F        ; Lagrar 0000 1111 i R16 för skrivning till DDRB.
   OUT DDRB, R16        ; Sätter PORTB0 - PORTB3 till utportar.

   MOVW R24, Y          ; Kopierar över RAMEND-adressen från Y till R24.
   ADIW R24, 1          ; Arrayens startadress sätts till RAMEND + 1, lagras i R25:R24.
   LDI R22, 16          ; Laddar arrayens storlek i R22.
   LDI R20, 0           ; Laddar arrayens startvärde i R20.
   LDI R18, 1           ; Laddar arrayens stegvärde i R18.
   RCALL assign         ; Fyller arrayen till bredden via anrop av subrutinen assign.

   MOVW R24, Y          ; Kopierar över RAMEND-adressen från Y till R24.
   ADIW R24, 1          ; Arrayens startadress sätts till RAMEND + 1, lagras i R25:R24.
   LDI R22, 16          ; Laddar arrayens storlek i R22.
   LDI R20, 0x25        ; Laddar &PORTB[7:0] i R20.
   LDI R21, 0x00        ; Laddar &PORTB[15:0] i R20.
   RCALL write          ; Skriver arrayens samtliga element en i taget till PORTB.

/********************************************************************************
* end: Programmets slutadress. Här stannar programmet.
********************************************************************************/
end:
   RJMP end             ; Genererar en tom loop.

