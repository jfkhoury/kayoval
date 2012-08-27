"use strict"

sinon = require("sinon")
knockoutValidator = require("..")

beforeEach ->
    @ko =
        utils: unwrapObservable: (x) => x
        bindingHandlers: {}
        extenders: {}
    knockoutValidator(@ko)

describe "ko.bindingHandlers.customValidation", ->
    beforeEach ->
        @valueAccessor = sinon.stub()

    describe "when customValidation is enabled", ->
        beforeEach ->
            @element = 
                setCustomValidity: sinon.spy()
        
            @valueAccessor.returns(true)

            @valueObservable = {}
            @allBindingsAccessor = sinon.stub().returns(value: @valueObservable)

        describe "when `valueObservable` has an `isValid` property and it returns true", ->
            beforeEach ->
                @valueObservable.isValid = => true

            it "should set customValidity to empty string", ->
                @ko.bindingHandlers.customValidation.update(@element, @valueAccessor, @allBindingsAccessor)

                @element.setCustomValidity.should.have.been.calledWith("")

        describe "when `valueObservable` has an `isValid` property and it returns false", ->
            beforeEach ->
                @valueObservable.isValid = => false
                @valueObservable.validationMessage = "INVALID MESSAGE"

            it "should set customValidity to validationMessage", ->
                @ko.bindingHandlers.customValidation.update(@element, @valueAccessor, @allBindingsAccessor)

                @element.setCustomValidity.should.have.been.calledWith("INVALID MESSAGE")

        describe "when `valueObservable` does not have an `isValid` property", ->
            beforeEach ->
                @valueObservable.validationMessage = "INVALID MESSAGE"
                @element.validity = {}
                @validGetter = sinon.stub()
                Object.defineProperty(@element.validity, "valid", { get: @validGetter })
                @ko.bindingHandlers.customValidation.update(@element, @valueAccessor, @allBindingsAccessor)

            it "should call `setCustomValidity` with an empty string before getting the `valid` property", ->
                @element.setCustomValidity.getCall(0).should.have.been.calledWith("")
                @element.setCustomValidity.getCall(0).should.have.been.calledBefore(@validGetter.getCall(0))

            describe

            it "should call `setCustomValidity` with an empty string if `element.validity.valid` is true", ->
                @validGetter.returns(true)
                @element.setCustomValidity.should.have.been.calledWith("")

            it "should call `setCustomValidity` with INVALID MESSAGE if `element.validity.valid` is false", ->
                @validGetter.returns(false)
                @element.setCustomValidity.should.have.been.calledWith("INVALID MESSAGE")
                