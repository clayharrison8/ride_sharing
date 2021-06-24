class AutoComplete {
  String mainText, secondaryText, id;

  // Getting key info from json response
  AutoComplete.fromJson(Map <String, dynamic> json){
    this.mainText = json["structured_formatting"]["main_text"];
    this.secondaryText = json["structured_formatting"]["secondary_text"];
    this.id = json["place_id"];
  }

}