window.$ = require('jquery')
window.jQuery = window.$
const hello = world=> {
    $('html').after(world)
}
hello("<p>Hello, world!</p>")
