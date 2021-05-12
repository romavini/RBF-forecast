%X=vetor ; W=tamanho da janela ; tt=porcentagem treinamento
function [Xfit, Xtest, Dfit, Dtest, Xend]=Janela(X, W, tt)
%Xx=matriz ; Xd=vetor desejado ; Xt=vetor teste ; Xtd=vetor teste desejado ; fXx=vetor teste final ; Mediat=Media total
format long

dicotomia=fix(size(X,1)*tt);

for i=1:size(X,1)-W
	for j=1:W
		if i>=dicotomia-W+1
			Xtest(i-dicotomia+W,j)=X(i+j-1,:);
		else
			Xfit(i,j)=X(i+j-1,:);
		end
	end
	if i>=dicotomia-W+1
		Dtest(i-dicotomia+W,:)=X(i+W,:);
	else
		Dfit(i,:)=X(i+W,:);
	end
end

Xend=Xtest(size(Xtest,1),2:size(Xtest,2));
Xend(:,size(Xend,2)+1)=Dtest(size(Dtest,1),:);

end