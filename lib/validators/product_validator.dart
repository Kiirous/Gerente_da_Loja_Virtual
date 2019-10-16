class ProductValidator {

  String validateImages(List images){
    if(images.isEmpty) return 'Adicione imagens do produto';
    return null;
  }

  String validateTitle(String text){
    if (text.isEmpty) return 'Preencha o título do produto';
    return null;
  }

  String validateDescription(String text){
    if(text.isEmpty) return 'Preencha a Descrição do produto';
    return null;
  }

  String validatePrice(String text){
    double price = double.tryParse(text); //Tenta transformar o preço inserido em double
    if(price != null){
      if(!text.contains(".") || text.split(".")[1].length != 2) // Verifica se nao contem ponto. Se não tiver retorta o texto.
        // Já o text.split pega valor digitado e divide no meio com um ponto '.' o [1] é para pegar sempre a segunta parte  e então verifica se a segunda parte tem 2 casas decimais.
        return 'Utilize duas casas decimais';
    } else {
      return 'Preço inválido';
    }

    return null; // Retornando nulo pq nunca vai chegar nesse caso.
  }
}