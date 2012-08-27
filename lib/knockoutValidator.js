"use strict";

function normalizeValue(value) {
    return value === undefined ? "" : value;
}

function setCustomValidity(valueObservable, element) {
    var isValid = false;
    if (valueObservable.isValid) {
        isValid = valueObservable.isValid();
    } else {
        element.setCustomValidity(""); // This makes `element.validity.valid` work correctly.
        isValid = element.validity.valid;
    }

    element.setCustomValidity(isValid ? "" : valueObservable.validationMessage);
}

module.exports = function (ko) {
    ko.bindingHandlers.customValidation = {
        update: function (element, valueAccessor, allBindingsAccessor) {
            var shouldCustomValidate = ko.utils.unwrapObservable(valueAccessor());

            if (shouldCustomValidate) {
                var valueObservable = allBindingsAccessor().value;

                setCustomValidity(valueObservable, element);
            }
        }
    };

    ko.extenders.customValidation = function (target, params) {
        if (params.mustMatch) {
            target.isValid = ko.computed(function () {
                return normalizeValue(target()) === normalizeValue(params.mustMatch());
            });
        }
        target.validationMessage = params.message;
        return target;
    };
};
