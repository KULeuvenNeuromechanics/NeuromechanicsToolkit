function [mtot] = getModelMass(ModelFile)
%getModelMass Computes to sum of all segment masses of an opensim model
%   input:
%       1) Modelfile: path to the opensim model
%
%   output:
%       1) mtot = total mass of the opensim model


import org.opensim.modeling.*
m = Model(ModelFile);
mtot = 0;

for i=1:m.getBodySet.getSize()
    mtot = mtot + m.getBodySet.get(i-1).getMass();
end




end