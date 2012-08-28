"use strict"

sinon = require("sinon")
knockoutValidator = require("..")

beforeEach ->
    @ko =
        utils: unwrapObservable: (x) => x
        bindingHandlers: {}
        extenders: {}
        computed: (y) => y
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

            describe "when `element.validity.valid` returns true", ->
                beforeEach ->
                    @validGetter.returns(true)

                it "should call `setCustomValidity` with an empty string if `element.validity.valid` is true", ->
                    @element.setCustomValidity.should.have.been.calledWith("")

            describe "when `element.validity.valid` returns false", ->
                beforeEach ->
                    @validGetter.returns(false)

                it "should call `setCustomValidity` with INVALID MESSAGE if `element.validity.valid` is false", ->
                    @element.setCustomValidity.should.have.been.calledWith("INVALID MESSAGE")


describe "ko.extenders.customValidation", ->
    beforeEach ->
        @target = sinon.stub()
        @params = message: "VALIDATION MESSAGE"
        

    describe "when params.mustMatch exists", ->
        beforeEach ->
            @target.returns("MUST MATCH VALUE")
            @params.mustMatch = sinon.stub()
            @ko.extenders.customValidation(@target, @params)

        it "should set the `isValid` computed property on target", ->
            @target.should.have.property("isValid")
        
        it "should set the validation message on the target", ->
            @target.should.have.property("validationMessage")
            @target.validationMessage.should.equal("VALIDATION MESSAGE")

        describe "when the target's value is undefined and other observable's value is empty string", ->
            beforeEach ->
                @target.returns(undefined)
                @params.mustMatch.returns("")

            it "isValid should return true", ->
                @target.isValid().should.equal(true)

        describe "when the target's value matches the other observable's value", ->
            beforeEach ->
                @target.returns("OBSERVABLE MATCH")
                @params.mustMatch.returns("OBSERVABLE MATCH")

            it "isValid should return true", ->
                @target.isValid().should.equal(true)

        describe "when the target's value does not match the other observable's value", ->
            beforeEach ->
                @target.returns("OBSERVABLE DOESN'T MATCH")
                @params.mustMatch.returns("OBSERVABLE MATCH")

            it "isValid should return false", ->
                @target.isValid().should.equal(false)

    describe "when params.mustMatch does not exists", ->
        beforeEach ->
            @target.returns("MUST MATCH VALUE")
            @ko.extenders.customValidation(@target, @params)

        it "should set the validation message on the target", ->
            @target.should.have.property("validationMessage")
            @target.validationMessage.should.equal("VALIDATION MESSAGE")
