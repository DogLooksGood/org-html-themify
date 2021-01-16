let toggleThemeBtn = document.getElementById('toggle-theme')
let toggleTocBtn = document.getElementById('toggle-toc')

toggleThemeBtn.addEventListener('click', function() {
  if (document.body.dataset.theme == 'dark') {
    document.body.dataset.theme = 'light'
    toggleThemeBtn.innerHTML = 'dark theme'
  } else {
    document.body.dataset.theme = 'dark'
    toggleThemeBtn.innerHTML = 'light theme'
  }

  document.body.classList.add('theme-transition')
  setTimeout(() => document.body.classList.remove('theme-transition'), 500)
})


let toc = document.getElementById('table-of-contents')

toggleTocBtn.addEventListener('click', function() {
  toc.classList.add('toc-show')
  toc.addEventListener('click', function() {
    toc.classList.remove('toc-show')
  })
})
