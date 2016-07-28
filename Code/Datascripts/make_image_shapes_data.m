close all
clear
clc

rng(1);

fpath = mfilename('fullpath');
rerfPath = fpath(1:strfind(fpath,'RandomerForest')-1);

Train = 1:10000;
Test = Train + 10000;
n = length(Train) + length(Test);
ns = [50 100 200];
ih = 32;
iw = ih;
p = ih*iw;

X_image = zeros(ih,iw,n);
[rowidx,colidx] = ind2sub([ih,iw],1:p);
radius = ceil(rand(1,n)*3) + 9;
Y = zeros(n,1);

%Class 0
for i = 1:n/2
    centroid(i,:) = randi(ih-radius(i)*2,1,2) + radius(i);
    x = zeros(ih,iw);
    x(sqrt(sum(([rowidx',colidx'] - repmat(centroid(i,:),p,1)).^2,2)) <= radius(i)) = 1;
    X_image(:,:,i) = x;
end

%Class 1
for i = n/2+1:n
    centroid(i,:) = randi(ih-radius(i)*2,1,2) + radius(i);
    x = zeros(ih,iw);
    x(abs(rowidx-centroid(i,1))<=radius(i)&abs(colidx-centroid(i,2))<=radius(i)) = 1;
    X_image(:,:,i) = x;
end
Y(n/2+1:end) = 1;

NewOrdering = randperm(n);
X_image = X_image(:,:,NewOrdering);
Y = Y(NewOrdering);
Labels = unique(Y);

Xtrain_image = X_image(:,:,Train);
Ytrain = Y(Train);
Xtest_image = X_image(:,:,Test);
Ytest = Y(Test);

ntrials = 10;

for k = 1:length(ns)
        nsub = ns(k);
    
    for trial = 1:ntrials

        Idx = [];
        for l = 1:length(Labels)
            Idx = [Idx randsample(find(Ytrain==Labels(l)),round(nsub/length(Labels)))'];
        end
        TrainIdx{k}(trial,:) = Idx(randperm(length(Idx)));
    end
end

save([rerfPath 'RandomerForest/Data/image_shapes_data.mat'],'ns','ntrials',...
    'Xtrain_image','Ytrain','Xtest_image','Ytest','TrainIdx')