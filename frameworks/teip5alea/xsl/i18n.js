// local i18next setup
//import i18next from 'i18next';

const unidir = /^[.,;:!?-|\[\]\(\)\{\}\s،۔؛]*$/;

// variables defaultLanguage, initialLanguage must be initialized before!
// resources should be set after this with i18next.addResourceBundle(...)

i18next
  .init({
    resources: {},
    lng: initialLanguage,
    fallbackLng: defaultLanguage,
    debug: true,
  }, function(err, t) {
    // init set content
    //updateContent();
  });

function updateContent() {
    // var el = document.getElementById("i18n-direction-indicator");
    // el.innerHTML = i18next.dir(i18next.language);

    var allElements = document.getElementsByTagName('*');
    for (var i = 0, n = allElements.length; i < n; i++) {
        // translate non-interpolation phrases
        var key = allElements[i].getAttribute('data-i18n-key');
        if (key !== null) {
            var namespace = allElements[i].getAttribute('data-i18n-ns');
            if (namespace == null) {
                namespace = defaultNamespace;
            }
            transl = i18next.t(key, { ns: namespace });
            if (unidir.test(transl)) {
                allElements[i].innerHTML = transl;
            } else {
                allElements[i].innerHTML = "".concat(directionPrefix(), transl, directionSuffix());
            }
        }
        // TODO: translate interpolation and pluralization phrases
    }
}

// register translation function
window.onload = updateContent;

function directionPrefix() {
    var dir = i18next.dir(i18next.language);
    if (dir == "rtl") {
        return "&#x202B;"; // right-to-left embedding
    } else {
        return "&#x202A;"; // left-to-right embedding
    }
}

function directionSuffix() {
    return "&#x202C;";
}

function changeLng(lng) {
  i18next.changeLanguage(lng);
}

i18next.on('languageChanged', () => {
  updateContent();
});
