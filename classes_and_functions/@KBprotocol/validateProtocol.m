function validateProtocol(obj)

validateResolution(obj)
validateSlabSelection(obj)
validateTEandTR(obj)
estimateNdummyScans(obj)
obj.isValidated = true;
fprintf('Tip: type: inputs, to double check the parameter values. \n\n')

end % end of validateProtocol