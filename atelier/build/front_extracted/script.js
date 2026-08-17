document.getElementById('getProverb').addEventListener('click', function() {
  fetch('https://ndvbyv7q63.execute-api.eu-west-3.amazonaws.com/prod/proverb')
    .then(response => response.json())
    .then(data => {
      document.getElementById('proverb').textContent = data.proverb;
    })
    .catch(error => console.error('Erreur:', error));
});
