let cookie = document.cookie.split('; ').find(r => r.startsWith('org_html_themify_theme'))
let theme = 'light'

if (cookie) {
  theme = cookie.split('=')[1]
}

let toggleThemeBtn = document.getElementById('toggle-theme')
let toggleTocBtn = document.getElementById('toggle-toc')

if (theme == 'light') {
  useLightTheme();
} else {
  useDarkTheme();
}

function transition() {
  document.body.classList.add('theme-transition')
  setTimeout(() => document.body.classList.remove('theme-transition'), 500)
}

function useLightTheme(theme) {
  document.body.dataset.theme = 'light'
  toggleThemeBtn.innerHTML = 'dark theme'
  document.cookie = 'org_html_themify_theme=light'
}

function useDarkTheme(theme) {
  document.body.dataset.theme = 'dark'
  toggleThemeBtn.innerHTML = 'light theme'
  document.cookie = 'org_html_themify_theme=dark'
}

toggleThemeBtn.addEventListener('click', function() {
  transition()
  if (document.body.dataset.theme == 'light') {
    useDarkTheme();
  } else {
    useLightTheme();
  }
})


let toc = document.getElementById('table-of-contents')

toggleTocBtn.addEventListener('click', function() {
  toc.classList.add('toc-show')
  toc.addEventListener('click', function() {
    toc.classList.remove('toc-show')
  })
})
