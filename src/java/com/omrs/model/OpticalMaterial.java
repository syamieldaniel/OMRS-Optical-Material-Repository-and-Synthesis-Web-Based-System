package com.omrs.model;

public class OpticalMaterial {
    private String id;
    private String name;
    private String chemicalFormula;
    private String category;
    private double wavelengthMinUm;
    private double wavelengthMaxUm;
    private String formulaDisplay;
    private String referenceTitle;
    private String referenceUrl;
    private String sourceUrl;
    private String comments;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getChemicalFormula() { return chemicalFormula; }
    public void setChemicalFormula(String chemicalFormula) { this.chemicalFormula = chemicalFormula; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public double getWavelengthMinUm() { return wavelengthMinUm; }
    public void setWavelengthMinUm(double wavelengthMinUm) { this.wavelengthMinUm = wavelengthMinUm; }
    public double getWavelengthMaxUm() { return wavelengthMaxUm; }
    public void setWavelengthMaxUm(double wavelengthMaxUm) { this.wavelengthMaxUm = wavelengthMaxUm; }
    public String getFormulaDisplay() { return formulaDisplay; }
    public void setFormulaDisplay(String formulaDisplay) { this.formulaDisplay = formulaDisplay; }
    public String getReferenceTitle() { return referenceTitle; }
    public void setReferenceTitle(String referenceTitle) { this.referenceTitle = referenceTitle; }
    public String getReferenceUrl() { return referenceUrl; }
    public void setReferenceUrl(String referenceUrl) { this.referenceUrl = referenceUrl; }
    public String getSourceUrl() { return sourceUrl; }
    public void setSourceUrl(String sourceUrl) { this.sourceUrl = sourceUrl; }
    public String getComments() { return comments; }
    public void setComments(String comments) { this.comments = comments; }
}
