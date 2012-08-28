"use strict"

sinon = require("sinon")
kayoval = require("..")

beforeEach ->
    @ko =
        utils: unwrapObservable: (x) => x
        bindingHandlers: {}
        extenders: {}
        computed: (y) =>
            y._isComputedObservable = true
            return y
    kayoval(@ko)

describe "ko.bindingHandlers.customValidation", ->
    beforeEach ->
        @valueAccessor = sinon.stub()

    describe "when customValidation is enabled", ->
        beforeEach ->
            @valueAccessor.returns(true)

            @element = setCustomValidity: sinon.spy()

            @valueObservable = {}
            @allBindingsAccessor = sinon.stub().returns(value: @valueObservable)

        describe "when `valueObservable` has an `isValid` property and it returns true", ->
            beforeEach ->
                @valueObservable.isValid = => true

            it "should call `setCustomValidity` with the empty string", ->
                @ko.bindingHandlers.customValidation.update(@element, @valueAccessor, @allBindingsAccessor)

                @element.setCustomValidity.should.have.been.calledWith("")

        describe "when `valueObservable` has an `isValid` property and it returns false", ->
            beforeEach ->
                @valueObservable.isValid = => false
                @valueObservable.validationMessage = "INVALID MESSAGE"

            it "should call `setCustomValidity` with the value of the observable's `validationMessage` property", ->
                @ko.bindingHandlers.customValidation.update(@element, @valueAccessor, @allBindingsAccessor)

                @element.setCustomValidity.should.have.been.calledWith("INVALID MESSAGE")

        describe "when `valueObservable` does not have an `isValid` property", ->
            beforeEach ->
                @valueObservable.validationMessage = "INVALID MESSAGE"

                @element.validity = {}

                @validGetter = sinon.stub()
                Object.defineProperty(@element.validity, "valid", { get: @validGetter })

                @ko.bindingHandlers.customValidation.update(@element, @valueAccessor, @allBindingsAccessor)

            it "should call `setCustomValidity` with the empty string before getting the `valid` property", ->
                @element.setCustomValidity.getCall(0).should.have.been.calledWith("")
                @element.setCustomValidity.getCall(0).should.have.been.calledBefore(@validGetter.getCall(0))

            describe "when `element.validity.valid` returns true", ->
                beforeEach ->
                    @validGetter.returns(true)

                it "should call `setCustomValidity` with the empty string", ->
                    @element.setCustomValidity.should.have.been.calledWith("")

            describe "when `element.validity.valid` returns false", ->
                beforeEach ->
                    @validGetter.returns(false)

                it "should call `setCustomValidity` with the value of the observable's `validationMessage` property", ->
                    @element.setCustomValidity.should.have.been.calledWith("INVALID MESSAGE")


describe "ko.extenders.customValidation", ->
    beforeEach ->
        @target = sinon.stub()
        @params = message: "VALIDATION MESSAGE"
        
    describe "when `params.mustMatch` exists", ->
        beforeEach ->
            @params.mustMatch = sinon.stub()
            @ko.extenders.customValidation(@target, @params)

        it "should set the `validationMessage` property on the target", ->
            @target.should.have.property("validationMessage").that.equals("VALIDATION MESSAGE")

        it "should set the `isValid` property on target to a computed observable", ->
            @target.should.have.property("isValid")
            @target.isValid.should.have.property("_isComputedObservable")
        
        describe "when the target's value is `undefined` and other observable's value is the empty string", ->
            beforeEach ->
                @target.returns(undefined)
                @params.mustMatch.returns("")

            it "isValid should return true", ->
                @target.isValid().should.be.true

        describe "when the target's value matches the other observable's value", ->
            beforeEach ->
                @target.returns("OBSERVABLE MATCH")
                @params.mustMatch.returns("OBSERVABLE MATCH")

            it "isValid should return true", ->
                @target.isValid().should.be.true

        describe "when the target's value does not match the other observable's value", ->
            beforeEach ->
                @target.returns("OBSERVABLE DOESN'T MATCH")
                @params.mustMatch.returns("OBSERVABLE MATCH")

            it "isValid should return false", ->
                @target.isValid().should.be.false

    describe "when params.mustMatch does not exist", ->
        beforeEach ->
            @target.returns("TARGET VALUE")
            @ko.extenders.customValidation(@target, @params)

        it "should set the `validationMessage` property on the target", ->
            @target.should.have.property("validationMessage").that.equals("VALIDATION MESSAGE")

        it "should not set the `isValid` property on the target", ->
            @target.should.not.have.property("isValid")
