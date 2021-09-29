function validateInputs(inputdata)
%validateInputs validates most of the input parameters. 
% 
%   validateInputs(inputs) takes inputs in the form a structure and
%   validate each input variale by restricting it to be of a certain
%   size, class and some other aspects, like being numeric, positive 
%   or, to belong to a certain group in the case of char variables.
%   Inputs
%   - inputdata: struct with input data to be validated. 
%   Outputs
%   - writes a validation message in the command window in case that all  
%     inputs are correctly validated, otherwise throws an error indicating  
%     which input parameter has inconsistencies.
% 
% Example: inputs.angularOrdering is restricted here to be  
% 'uniform' or 'goldenAngle', other case there will be an error.
%  
% this function has to be modified in case that new parameters are added, 
% deleted, or modified in 'Inputs' script.

% convert the inputs in struct format to name-value-pairs, to be able to 
% use the functionality: function argument validation in the next function. 
nameValuePairs = struct2pairs(inputdata);
performValidation(nameValuePairs{:})

end

function performValidation(inputs)
%performValidation checks if the values for the name-value-pairs inputs 
%make sense.
% For instance, inputs.nSpokes is expected to be a positive integer, 
% so any other value will throws an error indicating that fact.
%   Inputs
%   - inputs: name-value-pairs variables to be checked. 
%   Outputs
%   - Command window message validating the inputs.
arguments
    
    inputs.FOV (1,1) double {mustBeNumeric, mustBePositive}
    inputs.slabThickness (1,1) double {mustBeNumeric, mustBePositive}
    inputs.Nx (1,1) {mustBeNumeric, mustBeInteger, mustBePositive} 
    inputs.Nz (1,1) {mustBeNumeric, mustBeInteger, mustBePositive} 
    inputs.nSpokes (1,1) {mustBeNumeric, mustBeInteger, mustBePositive}
    inputs.bandwidthPerPixel (1,1) double {mustBeNumeric, mustBePositive}
    inputs.readoutOversampling (1,1) {mustBeMember(inputs.readoutOversampling, [1, 2])}
    inputs.nDummyScans (1,1) {mustBeNumeric, mustBeInteger, mustBeNonnegative}
    inputs.phaseDispersionZ (1,1) double {mustBeNumeric, mustBeNonnegative}
    inputs.phaseDispersionReadout (1,1) double {mustBeNumeric, mustBeNonnegative}
    inputs.GzSpoilerArea string {mustBeMember(inputs.GzSpoilerArea,{'adaptive', 'constant'})}   
    inputs.RfSpoilingIncrement (1,1) double {mustBeNumeric, mustBeNonnegative}
    inputs.angularOrdering string {mustBeMember(inputs.angularOrdering,{'uniform','uniformAlternating','goldenAngle'})}
    inputs.goldenAngleSequence (1,1) {mustBeNumeric, mustBeInteger, mustBePositive}
    inputs.angleRange string {mustBeMember(inputs.angleRange,{'fullCircle','halfCircle'})} 
    inputs.partitionRotation string {mustBeMember(inputs.partitionRotation,{'aligned','linear','goldenAngle'})}
    inputs.viewOrder string {mustBeMember(inputs.viewOrder,{'partitionsInInnerLoop','partitionsInOuterLoop'})} 
    inputs.RfExcitation string {mustBeMember(inputs.RfExcitation, {'selectiveSinc','nonSelective'})}
    inputs.RfPulseDuration(1,1) double {mustBeNumeric, mustBePositive}
    inputs.RfPulseApodization (1,1) double {mustBeMember(inputs.RfPulseApodization, [0, 0.2, 0.46, 0.5])} 
    inputs.timeBwProduct (1,1) double {mustBeNumeric, mustBePositive}
    inputs.maxGradient  (1,1) double {mustBeGreaterThan(inputs.maxGradient,0), mustBeLessThan(inputs.maxGradient,73)}
    inputs.maxSlewRate  (1,1) double {mustBeGreaterThan(inputs.maxSlewRate,0), mustBeLessThan(inputs.maxSlewRate,201)}
    inputs.TE (1,1) double {mustBeNumeric}
    inputs.TR (1,1) double {mustBeNumeric}
    inputs.flipAngle (1,1) double {mustBeGreaterThan(inputs.flipAngle,0), mustBeLessThan(inputs.flipAngle,90)}
    
end

fprintf('\n### All inputs have consistent values\n')
pause(1);

end


function C = struct2pairs(S)
% struct2pairs Turns a scalar struct S into a cell of string-value pairs C
%
%  C = struct2pairs(S)
%
% If S is a cell already, it will be returned unchanged.

% function taken from MATLAB answers: 
% https://www.mathworks.com/matlabcentral/answers/...
% 469700-how-to-pass-a-struct-as-name-value-pairs-to-a-function
if iscell(S)
 C = S; return
elseif length(S) > 1
    error 'Input must be a scalar struct or cell';
end
C = [fieldnames(S)'; struct2cell(S)'];
C = C(:)';

end
