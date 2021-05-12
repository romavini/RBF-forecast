 %x=matriz de amostras ; q=qntd de centros
function [C, MovC, Var, Group]=Distribuicao(x, q, nr)
%C=matriz de centros ; Var=matriz de aberturas
format long

ta = 0.1;
h=fix(size(x,1)/q);

for i=1:q
	C(i,:)=x(1+((i-1)*h),:);
end

cont = 0;
MovC{1,:}=C;
while true
	cont = cont +1;	
	Ci=C;
	Group=[];
	Group{size(x,1),size(C,1)} =[];
	for i=1:size(x,1)
		dmin = inf;
		for j=1:size(C,1)
			dist = (sqrt(sum(sum((x(i,:)-C(j,:)).^2))))^2;
			if dist < dmin
				dmin = dist;
				index = j;
			end
		end
		C(index,:) = C(index,:)+ta*(x(i,:)-C(index,:));
		Group{i, index} = (x(i,:)*nr);
	end
	if mod(cont, 50) == 0
		disp(['..........Calculando centros ', num2str(cont/50),':4......TA: ', num2str(ta),' ; Passo: ', num2str(sqrt(sum(sum((Ci-C).^2))))])
    end
    ta = ta*.99;
    MovC{cont+1,1}=(C*nr);
	if ((sum(sum(abs(Ci-C)))<0.5e-3) | (cont >= 200))
		break
    end
end
if size(Group,2) ~= q
	Group{:,q} = [];
end
C=C*nr;
%Abertura
Var(q,2) = 0;

for j=1:q
	cont=0;
	dsquare = [];
	for i=1:size(Group,1)
		if ~isempty(Group{i,j})
			dsquare(i,:) = sqrt((sum(sum((Group{i,j}-C(j,:)).^2)))^2);
			cont = cont+1;
		end
	end
	Var(j,1) = sum(dsquare);
	Var(j,1) = sqrt((Var(j,1))/(cont-1));
	if Var(j,1) == 0||(cont-1) < 1
		Var(j,1) = 1;
		Var(j,2) = 1;
	end
end

% if size(MovC,1)<=40
% for i=1:fix(size(MovC,1)/2)
% 	figure(i)
% 	hold on
% 	plot(x(:,1), x(:,2), 'ko','MarkerSize',15, 'MarkerFaceColor','k');
% 	if i~=size(MovC,1)
% 		for j=1:q
% 			plot(MovC{i*2-1,1}(j,1), MovC{i*2-1,1}(j,2), 'ro','MarkerSize',10, 'MarkerFaceColor','r');
% 		end
% 		hold;
% 	else
% 		for j=1:q
% 			plot(MovC{size(MovC,1),1}(j,1), MovC{size(MovC,1),1}(j,2), 'ro', 'MarkerSize',10, 'MarkerFaceColor','r');
% 		end
% 	end
% end
% for i=1:q
% 	viscircles([MovC{size(MovC,1), 1}(i,1), MovC{size(MovC,1), 1}(i,2)], Var(i));
% end
% hold;
% end
end