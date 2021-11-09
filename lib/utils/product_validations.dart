String? validateProductFields(String? formField) {
  return formField!.isNotEmpty ? null : "Field is required";
}
