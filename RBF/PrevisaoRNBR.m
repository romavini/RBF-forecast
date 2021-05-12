%[n1, n2]=intervalo neurônios; [j1, j2]=intervalo janela; passos=passos à frente.
function save=PrevisaoRNBR(n1, n2, j1, j2, passos)
format long
tic

create_plot = false
create_xls_file = false

Serie = '..\series\DolarPlus';
Ext='txt';
NameSerie = strcat(Serie, '.', Ext);
% X = xlsread(NameSerie);

fid=fopen(NameSerie, 'r');
X=fscanf(fid, '%f');
fclose(fid);

nr=norm(X);
X=X/nr;

tt=.9;
for i=n1:n2
	for j=j1:j2

		[Xfit, Xtest, Dfit, Dtest, Xend] = Janela(X, j, tt);
		[C, MovC, Raio, Group]=Distribuicao(Xfit, i, nr);
		[Y, Ypassos, EQM, EMA]=RNBR(Xfit, Dfit, Xtest, Dtest, Xend, Raio, C, passos);

		secs=toc;
		hour=fix((secs/3600));
		secs=secs - (hour*3600);
		minut=fix((secs/60));
		secs=secs - (minut*60);
		time=strcat(num2str(hour),'h',num2str(minut),'m',num2str(secs),'s');

		disp(['Serie:', NameSerie, ' ; N', num2str(i), 'J', num2str(j), ' ; EMA:', num2str(EMA*nr), ' ; ', time]);


		P.C{i,j}=C;
		P.MovC{i,j}=MovC;
		P.Raio{i,j}=Raio;
		P.Group{i,j}=Group;
		P.Xtest{i,j}=Xtest*nr;
		P.Dtest{i,j}=Dtest*nr;
		P.Xend{i,j}=Xend*nr;
		P.Y{i,j}=Y*nr;
		P.Ypassos{i,j}=Ypassos*nr;
		P.EQM(i,j)=EQM*nr;
		P.EMA(i,j)=EMA*nr;
	end
end
[TrocasePalpites]=CompraeVenda(n1, j1, P.Y, P.Dtest);
ml=-inf; %%ml = min lucro
ml(1,2:3)=0;
for i=n1:n2
	for j=j1:j2
		influcro{i,j}=strcat('BP:',num2str(TrocasePalpites{i,j}(1,1)),' ; MP:',num2str(TrocasePalpites{i,j}(1,2)),' ; BT:',num2str(TrocasePalpites{i,j}(1,3)),' ; MT:',num2str(TrocasePalpites{i,j}(1,4)),' ; L:',num2str(TrocasePalpites{i,j}(1,7)));

		if TrocasePalpites{i,j}(1,7)>ml(1,1)
			ml(1,1) = TrocasePalpites{i,j}(1,7);
			ml(1,2) = i;
			ml(1,3) = j;
		end
		caneraseLucro(i,j)=TrocasePalpites{i,j}(1,7);
	end
end

caneraseEMA=P.EMA;
for k=1:(n2-n1+1)*(j2-j1+1)
	minLucro(1,1)=-inf;
	minLucro(1,2)=0;
	minLucro(1,3)=0;

	minEMA(1,1)=inf;
	minEMA(1,2) = 0;
	minEMA(1,3) = 0;
	minEMA(1,4) = 0;
	minEMA(1,5) = 0;

	for i=n1:n2
		for j=j1:j2
			if caneraseEMA(i,j) < minEMA(1,1)
				minEMA(1,1) = caneraseEMA(i,j);
				minEMA(1,2) = P.EQM(i,j);
				minEMA(1,3) = i;
				minEMA(1,4) = j;
				minEMA(1,5) = TrocasePalpites{i,j}(1,7);
			end
			if caneraseLucro(i,j) > minLucro(1,1)
				minLucro(1,1) = caneraseLucro(i,j);
				minLucro(1,2)=i;
				minLucro(1,3)=j;
			end
		end
	end
					%%EMA		%%EQM		%%N			%%J        %%Lucro
	orgEMA(k,:)=[minEMA(1,1) minEMA(1,2) minEMA(1,3) minEMA(1,4) minEMA(1,5)];
	orgLucro(k,:)=[minLucro(1,1) minLucro(1,2) minLucro(1,3)];

	caneraseEMA(minEMA(1,3),minEMA(1,4))=inf;
	caneraseLucro(minLucro(1,2),minLucro(1,3))=-inf;
end

X=X*nr;

varia = 0; cont=0;
for i=(fix(size(X,1)*tt)+1):size(X,1)
	cont = cont+1;
	varia = varia+abs(X(i-1,:)-X(i));
end
varia=varia/cont;

secs=toc;
hour=fix((secs/3600));
secs=secs - (hour*3600);
minut=fix((secs/60));
secs=secs - (minut*60);
time=strcat(num2str(hour),'h',num2str(minut),'m',num2str(secs),'s');

% MÉDIA, DESVIO PADRÃO E COEFICIENTE DE VARIAÇÃO
mediaX=mean(X);
distmedia=0;
for i=1:size(X,1)
	distmedia=distmedia+(X(i,:)-mediaX)^2;
end
desviopadraoX=distmedia/(size(X,1)-1);
CoefVar=desviopadraoX/mediaX;

d1=[0 0 1];
d2=[.0 .45 .90];
d3=[.0 .89 .89];
d4=[.0 .89 .44];
d5=[.0 .89 .0];
d6=[.44 .89 .0];
d7=[.88 .88 .0];
d8=[.88 .44 .0];
d9=[1 .0 .0];

% QUARTIS
colorquartisEMA{n2,j2}=' ';
colorquartisLucro{n2,j2}=' ';
orgEMA(1,size(orgEMA,2)+1)=1;
orgLucro(1,size(orgLucro,2)+1)=1;
if size(orgEMA(:,1),1)>=9
	corteEMA=(orgEMA(size(orgEMA,1),1)-orgEMA(1,1))/9;
else
	corteEMA=(orgEMA(size(orgEMA,1),1)-orgEMA(1,1))/size(orgEMA,1);
end
for i=1:size(orgEMA,1)
	if i < corteEMA
		colorquartisEMA1{orgEMA(i,3),orgEMA(i,4)}='o';
		colorquartisEMA2{orgEMA(i,3),orgEMA(i,4)}=d1;
		orgEMA(i,size(orgEMA,2))=1;
	elseif i < corteEMA*2
		colorquartisEMA1{orgEMA(i,3),orgEMA(i,4)}='o';
		colorquartisEMA2{orgEMA(i,3),orgEMA(i,4)}=d2;
		orgEMA(i,size(orgEMA,2))=2;
	elseif i < corteEMA*3
		colorquartisEMA1{orgEMA(i,3),orgEMA(i,4)}='o';
		colorquartisEMA2{orgEMA(i,3),orgEMA(i,4)}=d3;
		orgEMA(i,size(orgEMA,2))=3;
	elseif i < corteEMA*4
		colorquartisEMA1{orgEMA(i,3),orgEMA(i,4)}='o';
		colorquartisEMA2{orgEMA(i,3),orgEMA(i,4)}=d4;
		orgEMA(i,size(orgEMA,2))=4;
	elseif i < corteEMA*5
		colorquartisEMA1{orgEMA(i,3),orgEMA(i,4)}='o';
		colorquartisEMA2{orgEMA(i,3),orgEMA(i,4)}=d5;
		orgEMA(i,size(orgEMA,2))=5;
	elseif i < corteEMA*6
		colorquartisEMA1{orgEMA(i,3),orgEMA(i,4)}='o';
		colorquartisEMA2{orgEMA(i,3),orgEMA(i,4)}=d6;
		orgEMA(i,size(orgEMA,2))=6;
	elseif i < corteEMA*7
		colorquartisEMA1{orgEMA(i,3),orgEMA(i,4)}='o';
		colorquartisEMA2{orgEMA(i,3),orgEMA(i,4)}=d7;
		orgEMA(i,size(orgEMA,2))=7;
	elseif i < corteEMA*8
		colorquartisEMA1{orgEMA(i,3),orgEMA(i,4)}='o';
		colorquartisEMA2{orgEMA(i,3),orgEMA(i,4)}=d8;
		orgEMA(i,size(orgEMA,2))=8;
	else
		colorquartisEMA1{orgEMA(i,3),orgEMA(i,4)}='o';
		colorquartisEMA2{orgEMA(i,3),orgEMA(i,4)}=d9;
		orgEMA(i,size(orgEMA,2))=9;
	end
end

contpos=0;
contneg=0;
for i=1:size(orgLucro,1)
	if orgLucro(i,1) <0
		contpos=contpos+1;
	elseif orgLucro(i,1) >0
		contneg=contneg+1;
	end
end
corteLucro1=orgLucro(1,1)/4;
corteLucro2=orgLucro(size(orgLucro,1),1)/4;
for i=1:size(orgLucro,1)
	if orgLucro(i,1) > corteLucro1*3
		colorquartisLucro1{orgLucro(i,2),orgLucro(i,3)}='o';
		colorquartisLucro2{orgLucro(i,2),orgLucro(i,3)}=d1;
		orgLucro(i,size(orgLucro,2))=1;
	elseif orgLucro(i,1) > corteLucro1*2
		colorquartisLucro1{orgLucro(i,2),orgLucro(i,3)}='o';
		colorquartisLucro2{orgLucro(i,2),orgLucro(i,3)}=d2;
		orgLucro(i,size(orgLucro,2))=2;
	elseif orgLucro(i,1) > corteLucro1*1
		colorquartisLucro1{orgLucro(i,2),orgLucro(i,3)}='o';
		colorquartisLucro2{orgLucro(i,2),orgLucro(i,3)}=d3;
		orgLucro(i,size(orgLucro,2))=3;
	elseif orgLucro(i,1) > 0
		colorquartisLucro1{orgLucro(i,2),orgLucro(i,3)}='o';
		colorquartisLucro2{orgLucro(i,2),orgLucro(i,3)}=d4;
		orgLucro(i,size(orgLucro,2))=4;
	elseif orgLucro(i,1) == 0
		colorquartisLucro1{orgLucro(i,2),orgLucro(i,3)}='o';
		colorquartisLucro2{orgLucro(i,2),orgLucro(i,3)}=d5;
		orgLucro(i,size(orgLucro,2))=5;
	elseif orgLucro(i,1) > corteLucro2
		colorquartisLucro1{orgLucro(i,2),orgLucro(i,3)}='o';
		colorquartisLucro2{orgLucro(i,2),orgLucro(i,3)}=d6;
		orgLucro(i,size(orgLucro,2))=6;
	elseif orgLucro(i,1) > corteLucro2*2
		colorquartisLucro1{orgLucro(i,2),orgLucro(i,3)}='o';
		colorquartisLucro2{orgLucro(i,2),orgLucro(i,3)}=d7;
		orgLucro(i,size(orgLucro,2))=7;
	elseif orgLucro(i,1) > corteLucro2*3
		colorquartisLucro1{orgLucro(i,2),orgLucro(i,3)}='o';
		colorquartisLucro2{orgLucro(i,2),orgLucro(i,3)}=d8;
		orgLucro(i,size(orgLucro,2))=8;
	else
		colorquartisLucro1{orgLucro(i,2),orgLucro(i,3)}='o';
		colorquartisLucro2{orgLucro(i,2),orgLucro(i,3)}=d9;
		orgLucro(i,size(orgLucro,2))=9;
	end
end


% PLOT
if create_plot == true

	figure(1)
	hold on
	for i=n1:n2
		for j=j1:j2
			plot(i,j,colorquartisEMA1{i,j},'color',colorquartisEMA2{i,j},'MarkerSize',12, 'MarkerFaceColor',colorquartisEMA2{i,j})
			% text(i,j,num2str(P.EMA(i,j)))
		end
	end
	title('Distribuicao por EMA');
	xlabel('N');
	ylabel('J');
	hold

	figure(2)
	hold on
	for i=n1:n2
		for j=j1:j2
			plot(i,j,colorquartisLucro1{i,j},'color',colorquartisLucro2{i,j},'MarkerSize',12,'MarkerEdgeColor',colorquartisLucro2{i,j},'MarkerFaceColor',colorquartisLucro2{i,j})
			% text(i,j,num2str(P.EMA(i,j)))
		end
	end
	title('Distribuicao por Lucro');
	xlabel('N');
	ylabel('J');
	hold

	figure(3)
	hold on
	for i=n1:n2
		for j=j1:j2
			plot(i,j,colorquartisLucro1{i,j},'color',colorquartisLucro2{i,j},'MarkerSize',12,'MarkerEdgeColor',colorquartisLucro2{i,j},'MarkerFaceColor',colorquartisLucro2{i,j})
			plot(i,j,colorquartisEMA1{i,j},'color',colorquartisEMA2{i,j},'MarkerSize',5, 'MarkerFaceColor',colorquartisEMA2{i,j})
			% text(i,j,num2str(P.EMA(i,j)))
		end
	end
	title('Distribuicao por Lucro e por EMA');
	xlabel('N');
	ylabel('J');
	hold

	figure(4)
	x=[1:size(Y,1)]';
	plot(x,P.Y{orgEMA(1,3),orgEMA(1,4)},'b--x',x,P.Dtest{orgEMA(1,3),orgEMA(1,4)},'r--x')
	T=['Melhor Verificacao: N',num2str(orgEMA(1,3)),'J',num2str(orgEMA(1,4))];
	title(T);
	grid on
	grid minor

	if ((n2-n1+1)*(j2-j1+1)) >= 10
		for i=1:10
			figure(i+4)
			x=[1:passos]';
			plot(x,P.Ypassos{orgEMA(i,3),orgEMA(i,4)},'b-.s')
			T=['Previsão  N',num2str(orgEMA(i,3)),'J',num2str(orgEMA(i,4))];
			title(T)
			grid on
			grid minor
		end
	else
		figure(5)
		x=[1:passos]';
		plot(x,P.Ypassos{orgEMA(1,3),orgEMA(1,4)},'b-.s')
		T=['Previsao  N',num2str(orgEMA(1,3)),'J',num2str(orgEMA(1,4))];
		title(T)
		grid on
		grid minor
	end
end


%DOCUMENTANDO EM EXCEL
if create_xls_file == true
	warning('off','MATLAB:xlswrite:AddSheet');
	cl=clock;
	namefile=['MakeSimple;'];
	for i=1:size(cl,2)
		namefile=strcat(namefile, num2str(cl(1,i)),';');
	end

	namefile=strcat(namefile,'N',num2str(n1),',',num2str(n2),';J',num2str(j1),',',num2str(j2),';', Serie, ';', Ext, ';', time, '.xlsx');

	f=strcat('de	',num2str(n1),' a	',num2str(n2));
	g=strcat('de	',num2str(j1),' a	',num2str(j2));
	C={'Neuronios:', f;'Janela:', g;'Serie:',NameSerie;'Tempo:',time};
	xlswrite(namefile,C,'Sheet1','A1');

	f=strcat('N',num2str(orgEMA(1,3)),'J',num2str(orgEMA(1,4)));
	C={'Melhor Verificacao:',f;'EMA:',num2str(orgEMA(1,1));'EQM:',num2str(orgEMA(1,2));'Variacao Media Absoluta:',num2str(varia);'Previsao:',num2str(P.Ypassos{orgEMA(1,3),orgEMA(1,4)}(1,1))};
	xlswrite(namefile,C,'Sheet1','A6');

	if ((n2-n1+1)*(j2-j1+1)) >= 5
		for i=1:5
			h{i,1}=strcat('N',num2str(orgEMA(i,3)),'J',num2str(orgEMA(i,4)));
			h{i,2}=strcat('EMA:',num2str(orgEMA(i,1)));
			h{i,3}=strcat('EQM:',num2str(orgEMA(i,2)));
			h{i,4}=influcro{orgEMA(i,3),orgEMA(i,4)};
		end
		C={'Previsoes:','','','','','';'Colocacao:', h{1,1}, h{2,1}, h{3,1}, h{4,1}, h{5,1}};
		xlswrite(namefile,C,'Sheet1','A12');
		C={'Erro Medio Absoluto (EMA):', h{1,2}, h{2,2}, h{3,2}, h{4,2}, h{5,2};'Erro Quadratico Medio (EQM):', h{1,3}, h{2,3}, h{3,3}, h{4,3}, h{5,3};'Palpites, trocas e lucro:', h{1,4}, h{2,4}, h{3,4}, h{4,4}, h{5,4}};
		xlswrite(namefile,C,'Sheet1','A14');
		C{1,1}={};
		for i=1:passos
			sad=strcat('Valor ', num2str(i));
			C(i,:)={sad, P.Ypassos{orgEMA(1,3),orgEMA(1,4)}(i,:), P.Ypassos{orgEMA(2,3),orgEMA(2,4)}(i,:), P.Ypassos{orgEMA(3,3),orgEMA(3,4)}(i,:), P.Ypassos{orgEMA(4,3),orgEMA(4,4)}(i,:), P.Ypassos{orgEMA(5,3),orgEMA(5,4)}(i,:)};
		end
		xlswrite(namefile,C,'Sheet1','A17');
	else
		h{1,1}=strcat('N',num2str(orgEMA(1,3)),'J',num2str(orgEMA(1,4)));
		h{1,2}=strcat('EMA:',num2str(orgEMA(1,1)));
		h{1,3}=strcat('EQM:',num2str(orgEMA(1,2)));
		h{1,4}=influcro{orgEMA(1,3),orgEMA(1,4)};

		C={'Previsoes:','';'Colocacao:', h{1,1}};
		xlswrite(namefile,C,'Sheet1','A12');
		C={'Erro Medio Absoluto (EMA):', h{1,2};'Erro Quadratico Medio (EQM):', h{1,3};'Palpites, trocas e lucro:', h{1,4}};
		xlswrite(namefile,C,'Sheet1','A14');
		C{1,1}={};
		for i=1:passos
			sad=strcat('Valor ', num2str(i));
			C(i,:)={sad, P.Ypassos{orgEMA(1,3),orgEMA(1,4)}(i,:)};
		end
		xlswrite(namefile,C,'Sheet1','A17');
	end

	sad=strcat('Config N', num2str(ml(1,2)), 'J', num2str(ml(1,3)));
	C={'Destaque para:',sad;'EMA:', P.EMA(ml(1,2),ml(1,3));'EQM:',P.EQM(ml(1,2),ml(1,3))};
	xlswrite(namefile,C,'Sheet1','H13');
	C={'Compras: ',influcro{ml(1,2),ml(1,3)}};
	xlswrite(namefile,C,'Sheet1','H16');

	for d=1:passos
		sad=strcat('Valor ', num2str(d));
		C(d,:)={sad, P.Ypassos{ml(1,2),ml(1,3)}(d,:)};
	end
	xlswrite(namefile,C,'Sheet1','H17');

	xlswrite(namefile,{'EMA', 'EQM', 'N', 'J', 'Lucro'},'Rank EMA','A1');
	xlswrite(namefile,orgEMA,'Rank EMA','B1');

	xlswrite(namefile,{'Lucro', 'N', 'J'},'Rank Lucro','A1');
	xlswrite(namefile,orgLucro,'Rank Lucro','B1');

	xlswrite(namefile,'N','colorquartisEMA1','A2');
	xlswrite(namefile,'J','colorquartisEMA1','B1');
	xlswrite(namefile,colorquartisEMA1,'colorquartisEMA1','B2');
	xlswrite(namefile,'N','colorquartisEMA2','A2');
	xlswrite(namefile,'J','colorquartisEMA2','B1');
	xlswrite(namefile,colorquartisEMA2,'colorquartisEMA2','B2');

	xlswrite(namefile,'N','colorquartisLucro1','A2');
	xlswrite(namefile,'J','colorquartisLucro1','B1');
	xlswrite(namefile,colorquartisLucro1,'colorquartisLucro1','B2');
	xlswrite(namefile,'N','colorquartisLucro2','A2');
	xlswrite(namefile,'J','colorquartisLucro2','B1');
	xlswrite(namefile,colorquartisLucro2,'colorquartisLucro2','B2');

	xlswrite(namefile,'N','P.EMA','A2');
	xlswrite(namefile,'J','P.EMA','B1');
	xlswrite(namefile,P.EMA,'P.EMA','B2');

	xlswrite(namefile,{'Coeficiente de variacao:', CoefVar},NameSerie,'A1');
	xlswrite(namefile,X,NameSerie,'A3');

	disp(namefile);
	disp(time);
end

save.colorquartisEMA = colorquartisEMA;
save.colorquartisLucro = colorquartisLucro;
save.EMA = P.EMA;

end
