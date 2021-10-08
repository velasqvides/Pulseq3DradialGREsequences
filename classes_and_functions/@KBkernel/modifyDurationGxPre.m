function GxPreModified = modifyDurationGxPre(obj)
[~, ~, GzReph] = createSlabSelectionEvents(obj);
sys = obj.protocol.systemLimits;
[~, GxPre, ~] = createReadoutEvents(obj);

if isempty(GzReph) % GxPre does not need modifications in duration
    GxPreModified = GxPre;
else % modify the duration to accept more area (GzReph.area) later
    GzRephArea = GzReph.area;
    GxPreArea = GxPre.area;
    % we want to know how much time is required to apply a gradient which is
    % equal to the sum of the two gradients GzReph and GxPre
    dummyGxPre = mr.makeTrapezoid('x', sys, 'Area', GzRephArea + GxPreArea);
    % extract the duration described in the comment above
    durationDummyGxPre = mr.calcDuration(dummyGxPre);
    % recalculate GxPre with the same area as before but with potentially larger duration
    GxPreModified = mr.makeTrapezoid('x',sys,'Area',GxPreArea,'Duration',durationDummyGxPre);
end
end
