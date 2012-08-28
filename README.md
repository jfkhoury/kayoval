# Kayoval

**Kayoval** customizes your HTML5 validation by extending your [Knockout][] view models.

Here's a quick example:

```html
<input data-bind="value: password" type="password" required="required" />
<input data-bind="customValidation: true, value: confirmPassword" type="password" />
```

```js
viewModel.password = ko.observable().extend({
    customValidation: {
        message: "You must enter a password."
    }
});

viewModel.confirmPassword = ko.observable().extend({
    customValidation: {
        mustMatch: viewModel.password,
        message: "Your passwords must match."
    }
});
```

Right now we just have the `mustMatch` validation rule, but it's very pluggable if you can think of other rules! And
you can use `message` independently of `mustMatch`, so even if you just want a different error message for the
`required` attribute (or `pattern`, or whatever), we've got you covered!

## Usage

Kayoval is packaged as a [Node.js][] module, meant for use with a system like [Browserify][].

[Node.js]: http://nodejs.org/
[Knockout]: http://knockoutjs.com/
[Browserify]: https://github.com/substack/node-browserify
