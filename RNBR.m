function [Y, Ypassos, MSE, EMA]=RNBR(Xfit, Dfit, Xtest, Dtest, Xend, DesvPad, C, passos)
format long

f = @(x,y,z) exp((-(sqrt(sum((x-y).^2)))^2)/2*z);

for i = 1:size(Xfit,1)
	for j = 1:size(C,1)
		G(i, j) = f(Xfit(i,:), C(j,:), DesvPad(j,1));
	end
	G(i,(size(C,1)+1))=1;
end

for i=1:size(G,1)
	for j=1:size(G,2)
		if G(i,j)==inf||isnan(G(i,j))
			G(i,j)=0;
			disp(' ')
			disp(';;;;;;;;;;;;; Algo errado na matrix G, em RNBR (NaN || Inf) ;;;;;;;;;;;;;')
			disp(' ')
		end
	end
end
Gpinv = pinv(G);
W = Gpinv*Dfit;

B(1, (size(C,1)+1)) = 1;

for i = 1:size(Xtest,1)
	for j=1:size(C,1)
		B(1,j) = f(Xtest(i,:),C(j,:),DesvPad(j,1));
	end
	Y(i,1) = B*W;
	Erro(i,1) = abs(Y(i,1) - Dtest(i,:));
	Erro(i,2) = (Y(i,1) - Dtest(i,:))^2;
end

EMA=sum(Erro(:,1))/size(Xtest,1);
MSE=sum(Erro(:,2))/size(Xtest,1);


D(1, (size(C,1)+1)) = 1;
for i = 1:passos
	for j = 1:size(C,1)
		D(1, j) = f(Xend,C(j,:),DesvPad(j,1));
	end
	Ypassos(i,:) = D*W;
	Xend(1,size(Xend,2)+1)=Ypassos(i,:);
	Xend(:,1)=[];
end
end