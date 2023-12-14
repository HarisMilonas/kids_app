class CustomValidators {

  get timeValidator => (value) {
        final RegExp timeExp = RegExp(r'^(0?[0-9]|1[0-9]|2[0-3]):[0-9]+$');
        if (value == null || value.isEmpty || value.trim().isEmpty) {
          return "Πρέπει να το συμπληρώσεις!";
        }
        if (!timeExp.hasMatch(value.trim())) {
          return 'Συμπλήρωσε 12:00 με αυτό τον τρόπο';
        }
      
        return null;
      };

}
