% compute JOL for each trial

load BIMresults_study3_outputX0.mat
load beliefData_study3.mat

pexp1 = params{1}(:,1);
pexp2 = params{2}(:,1);
mconf1 = params{1}(:,2);
mconf2 = params{2}(:,2);

sigmal1 = sqrt(1./pexp1-1);
sigmal2 = sqrt(1./pexp2-1);

wavg1 = norminv(mconf1).*sqrt(1+sigmal1.^2+1./(sigmal1.^2));
wavg2 = norminv(mconf2).*sqrt(1+sigmal2.^2+1./(sigmal2.^2));

mub1 = norminv(belief(:,1));
mub2 = norminv(belief(:,2));

mue1 = sigmal1.*(wavg1 - mub1.*sigmal1);
mue2 = sigmal2.*(wavg2 - mub2.*sigmal2);

% use mu_e in one condition to predict mu_e in the other condition
mue1_est = mue2;
mue2_est = mue1;

% use mean JOLs to estimate the mconf parameter
subID = sort(unique(jol_data(:,1)));
conditionID = sort(unique(jol_data(:,2)));
nsubj = length(subID);

mconf1_est = zeros(nsubj,1);
mconf2_est = zeros(nsubj,1);

for i = 1:nsubj
    
    jol_data_sub = jol_data(jol_data(:,1)==subID(i),:);
    jol_data_sub1 = jol_data_sub(jol_data_sub(:,2)==conditionID(1),:);
    jol_data_sub2 = jol_data_sub(jol_data_sub(:,2)==conditionID(2),:);
    
    mconf1_est(i,1) = mean(jol_data_sub1(:,3))/100;
    mconf2_est(i,1) = mean(jol_data_sub2(:,3))/100;
    
end

% estimate sigmal
sigmal1_est = zeros(nsubj,1);
sigmal2_est = zeros(nsubj,1);

for i = 1:nsubj
    
    sigmal1_est(i,1) = func_estSigmal(mconf1_est(i,1),mue1_est(i,1),mub1(i,1));
    sigmal2_est(i,1) = func_estSigmal(mconf2_est(i,1),mue2_est(i,1),mub2(i,1));
    
end

% estimate a and b
wavg1_est = norminv(mconf1_est).*sqrt(1+sigmal1_est.^2+1./(sigmal1_est.^2));
wavg2_est = norminv(mconf2_est).*sqrt(1+sigmal2_est.^2+1./(sigmal2_est.^2));

a1_est = 1./(sigmal1_est.*sqrt(sigmal1_est.^2+1));
a2_est = 1./(sigmal2_est.*sqrt(sigmal2_est.^2+1));

b1_est = wavg1_est./sqrt(sigmal1_est.^2+1);
b2_est = wavg2_est./sqrt(sigmal2_est.^2+1);

% predict jol in one condition based on the X0 values from the other
% condition

X0_con1 = cell2mat(X0{1});
X0_con2 = cell2mat(X0{2});

a1_est = repmat(a1_est,[1 size(X0_con1,2)]);
a2_est = repmat(a2_est,[1 size(X0_con2,2)]);

b1_est = repmat(b1_est,[1 size(X0_con1,2)]);
b2_est = repmat(b2_est,[1 size(X0_con2,2)]);

jol1 = normcdf(a1_est.*X0_con2+b1_est);
jol2 = normcdf(a2_est.*X0_con1+b2_est);

jol1 = reshape(jol1',numel(jol1),1);
jol2 = reshape(jol2',numel(jol2),1);

computed_jol_data = [jol1;jol2]*100;