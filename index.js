window.$ = require('jquery')
window.jQuery = window.$
const hello = world=> {
    $('html').after(world)
}
hello("<p>Hello, strange world!</p>")
