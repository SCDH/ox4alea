// import i18next from 'i18next';

i18next
  .init({
    resources,
    fallbackLng: 'en',
    debug: true,
  }, function(err, t) {
    // init set content
    updateContent();
  });

function updateContent() {
    allElements = document.getElementsByTagName('*');
    for (var i = 0, n = allElements.length; i < n; i++) {
	// translate non-interpolation phrases
	var key = allElements[i].getAttribute('data-i18n-key');
	if (key !== null) {
	    allElements[i].innerHTML = i18next.t(key);
	}
	// TODO: translate interpolation and pluralization phrases
    }
}

function changeLng(lng) {
  i18next.changeLanguage(lng);
}

i18next.on('languageChanged', () => {
  updateContent();
});
