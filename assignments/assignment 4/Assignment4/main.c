#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdbool.h>
#include "main.h"
#include "lcd_drv.h"

// Global timekeeping variables
volatile int sub_seconds = 0;  ///< Milliseconds counter (0-999)
volatile int seconds = 0;      ///< Seconds counter (0-59)
volatile int minutes = 0;      ///< Minutes counter (0-59)
volatile int hours = 0;        ///< Hours counter
volatile bool timer_paused = false; ///< Pause state flag for secondary timer

/**
 * @brief Initialize Timer1 for 1ms interrupts
 * 
 * Configures Timer1 in CTC mode with:
 * - Prescaler: 8
 * - OCR1A: 1999
 * Resulting in 1ms interrupts (16MHz/8/2000 = 1000Hz)
 */
void timer1_init() {
    TCCR1A = 0;                 ///< Clear Timer1 control registers
    TCCR1B = 0;
    OCR1A = 1999;               ///< Set compare match value
    TCCR1B |= (1 << WGM12);     ///< Enable CTC mode
    TCCR1B |= (1 << CS11);      ///< Set prescaler to 8
    TIMSK1 |= (1 << OCIE1A);    ///< Enable timer compare interrupt
}

/**
 * @brief Initialize ADC for button input
 * 
 * Configures ADC with:
 * - Reference: AVCC
 * - Prescaler: 128
 */
void init_buttons() {
    ADCSRA = (1 << ADEN) |      ///< Enable ADC
             (1 << ADPS2) |     ///< Set ADC prescaler to 128
             (1 << ADPS1) | 
             (1 << ADPS0);
    ADMUX = (1 << REFS0);       ///< Set reference voltage to AVCC
}

/**
 * @brief Check if select button is pressed
 * @return uint8_t 1 if button is pressed (ADC value 555-789), 0 otherwise
 */
uint8_t check_select_button() {
    ADCSRA |= (1 << ADSC);              ///< Start ADC conversion
    while (ADCSRA & (1 << ADSC));       ///< Wait for conversion complete
    return (ADC >= 555 && ADC < 790);   ///< Check against button voltage range
}

/**
 * @brief Timer1 compare interrupt service routine (1ms interval)
 * 
 * Updates timekeeping variables and refreshes LCD display:
 * - Line 0: Always shows current time (master clock)
 * - Line 1: Shows current time only when not paused
 */
ISR(TIMER1_COMPA_vect) {
    increment_timer();  ///< Update time variables
    
    // Format and display time
    char running_time[16];
    sprintf(running_time, "%02d:%02d:%02d.%03d", hours, minutes, seconds, sub_seconds);
    
    // Master clock (always displayed)
    lcd_xy(0, 0);
    lcd_puts(running_time);
    
    // Secondary timer (pausable)
    if(!timer_paused) {
        lcd_xy(0, 1);
        lcd_puts(running_time);
    }
}

/**
 * @brief Increment timekeeping variables
 * 
 * Handles rollover for:
 * - milliseconds -> seconds
 * - seconds -> minutes
 * - minutes -> hours
 */
void increment_timer() {
    sub_seconds++;
    if(sub_seconds > 999) {
        sub_seconds = 0;
        seconds++;
        if(seconds > 59) {
            seconds = 0;
            minutes++;
            if(minutes > 59) {
                minutes = 0;
                hours++;
            }
        }
    }
}

/**
 * @brief Main application entry point
 * 
 * Initializes hardware and enters main loop:
 * 1. LCD initialization
 * 2. Button input setup
 * 3. Timer1 initialization
 * 4. Global interrupt enable
 * 
 * Main loop monitors select button to toggle pause state
 */
int main(void) {
    // Hardware initialization
    lcd_init();
    init_buttons();
    timer1_init();
    sei();  ///< Enable global interrupts
    
    // Main application loop
    while(1) {
        if(check_select_button()) {
            timer_paused = !timer_paused;  ///< Toggle pause state on button press
        }
    }
}