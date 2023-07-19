%% a few landmark correspondences (to avoid symmetry flipping).
 
landmarks1 = [686, 473, 486, 841, 538, 769, 735, 665]';
landmarks2 = [873, 597, 622, 675, 701, 761, 793, 841]';
landmarks = [landmarks1 landmarks2(:,1)];

landmarks1 = [1, 116, 125, 148, 209]';
landmarks2 = [1, 143, 152, 186, 262]';
landmarks = [landmarks1 landmarks2(:,1)];

%% J letter
landmarks1 = [219, 128, 516, 486, 325, 254, 765, 823, 653, 987, 959]';
landmarks2 = [279, 190, 4, 508, 359, 311, 785, 829, 691, 1015, 993]';
landmarks = [landmarks1 landmarks2(:,1)];

%% Leaves

landmarks1 = [3815, 2737, 2700, 2291, 2208, 2508, 2623, 2384, 2470, 964, 704];
landmarks2 = [4668, 2906, 2844, 2397, 2234, 3107, 3033, 2521, 2671, 693, 370];
landmarks = [landmarks1 landmarks2(:,1)];
