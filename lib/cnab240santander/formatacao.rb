module Cnab240santander
  module Formatacao
    def formata_data(dt)
      if dt.split("").uniq != ["0"]
        return DateTime.strptime(dt[0..1]+"/"+dt[2..3]+"/"+dt[4..7], "%d/%m/%Y").strftime('%d/%m/%Y')
      end
    end

    def prepara_moeda(n, digitos)
      return (n.to_f)/(10**digitos)
    end
  end
end