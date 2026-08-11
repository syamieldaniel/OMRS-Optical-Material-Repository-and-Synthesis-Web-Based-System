package com.omrs.model;

public class OpticalCalculationResult {
    private double wavelengthUm;
    private double refractiveIndex;
    private double extinctionCoefficient;
    private double epsilon1;
    private double epsilon2;
    private double absorptionCoefficientCm;
    private double reflectance;
    private Double thicknessValue;
    private String thicknessUnit;
    private Double internalTransmission;
    private Double singlePassTransmission;

    public double getWavelengthUm() { return wavelengthUm; }
    public void setWavelengthUm(double wavelengthUm) { this.wavelengthUm = wavelengthUm; }
    public double getRefractiveIndex() { return refractiveIndex; }
    public void setRefractiveIndex(double refractiveIndex) { this.refractiveIndex = refractiveIndex; }
    public double getExtinctionCoefficient() { return extinctionCoefficient; }
    public void setExtinctionCoefficient(double extinctionCoefficient) { this.extinctionCoefficient = extinctionCoefficient; }
    public double getEpsilon1() { return epsilon1; }
    public void setEpsilon1(double epsilon1) { this.epsilon1 = epsilon1; }
    public double getEpsilon2() { return epsilon2; }
    public void setEpsilon2(double epsilon2) { this.epsilon2 = epsilon2; }
    public double getAbsorptionCoefficientCm() { return absorptionCoefficientCm; }
    public void setAbsorptionCoefficientCm(double absorptionCoefficientCm) { this.absorptionCoefficientCm = absorptionCoefficientCm; }
    public double getReflectance() { return reflectance; }
    public void setReflectance(double reflectance) { this.reflectance = reflectance; }
    public Double getThicknessValue() { return thicknessValue; }
    public void setThicknessValue(Double thicknessValue) { this.thicknessValue = thicknessValue; }
    public String getThicknessUnit() { return thicknessUnit; }
    public void setThicknessUnit(String thicknessUnit) { this.thicknessUnit = thicknessUnit; }
    public Double getInternalTransmission() { return internalTransmission; }
    public void setInternalTransmission(Double internalTransmission) { this.internalTransmission = internalTransmission; }
    public Double getSinglePassTransmission() { return singlePassTransmission; }
    public void setSinglePassTransmission(Double singlePassTransmission) { this.singlePassTransmission = singlePassTransmission; }
}
