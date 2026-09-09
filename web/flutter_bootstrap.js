// Avvio dell'applicazione web. Il modello predefinito innesta Flutter
// nell'intera pagina; qui gli si indica un elemento ospite, perché la
// rientranza dalle zone riservate del dispositivo sia governabile in CSS e
// perché la dichiarazione `viewport` di `index.html` non venga sostituita
// (vedi decisioni.md).
{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    hostElement: document.querySelector('#healthylog'),
  },
});
