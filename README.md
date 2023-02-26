# Pekare och arrayer i assembler
Demonstration av pekarregister X, Y och Z i AVR assembler för skrivning och läsning till specifika adresser.
Användning av instruktioner MOVW, ST och LD samt makrot RAMEND.
Motsvarande C-kod demonstreras också.

En statisk array, som lagras på adress RAMEND + 1 (0x0900) till RAMEND + 16 (0x090F), implementeras. 
Arraryen tilldelas binära kombinationer 0000 - 1111 via en subrutin döpt assign, där en pekare till arrayen
passeras tillsammans med dess storlek samt start- och stegvärde för tilldelning

Samtliga binära kombinationer hämtas sedan en efter en och skrivs till PORTB via en subrutin döpt write,
där en pekare till arrayen passeras tillsammans med dess storlek samt adressen till PORTB.

Filen "main.asm" demonstrerar programmet i AVR assembler.
Filen "main.c" demonstrerar motsvarande programkod i C.

Se video tutorial här:
https://youtu.be/PfmESwsfcQA