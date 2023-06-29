package com.example;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

public class CalculatorTest {
    @Test
    public void testAdd() {
        Calculator calculator = new Calculator();
        int result = calculator.add(2, 3);
        Assertions.assertEquals(5, result);
    }

    @Test
    public void testSubtract() {
        Calculator calculator = new Calculator();
        int result = calculator.subtract(5, 3);
        Assertions.assertEquals(2, result);
    }

    @Test
    public void testMultiple() {
        Calculator calculator = new Calculator();
        int result = calculator.multiply(5, 3);
        Assertions.assertEquals(15, result);
    }

    @Test
    public void testDivide() {
        Calculator calculator = new Calculator();
        int result = calculator.divide(15, 3);
        Assertions.assertEquals(5, result);
    }
}
