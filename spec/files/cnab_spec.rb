require "spec_helper"

describe "Cnab240santander" do
  it "includes ActiveSupport" do
    Object.class_eval { const_defined?("ActiveSupport") }.should be_truthy
  end
  
  it "raises an exception when :path options is nil" do
    expect { Cnab240santander.retorno }.to raise_error(ArgumentError)
  end
  
  it "returns an array" do
    cnab = Cnab240santander.retorno(path: File.dirname(__FILE__)+"/../../RETORNO.TXT", retorna: nil)
    cnab.linhas.should be_kind_of(Array)
  end

  context "Header file" do
    it "parses the header file" do
      cnab = Cnab240santander.retorno(path: File.dirname(__FILE__)+"/../../RETORNO.TXT", retorna: 0)
      cnab.linhas.should be_kind_of(Array)
    end
  end

  context "Details merged" do
    it "parses the details and merge the U and T segments" do
      cnab = Cnab240santander.retorno(path: File.dirname(__FILE__)+"/../../RETORNO.TXT", retorna: 3, merge: true)
      cnab.linhas.should be_kind_of(Array)
    end
  end
end