function plotMemFun(obj, iObj, extPercent)

p10 = obj.problemCfg.membershipFunctions{iObj}.p10;
p90 = obj.problemCfg.membershipFunctions{iObj}.p90;
ranges = [p10, p90];
memFun = obj.membershipFuncs{iObj};

x = linspace(min(ranges) - abs(min(ranges))*extPercent, ...
    max(ranges) + abs(max(ranges))*extPercent, ...
    100);

y = memFun(x);

plot(x, y, 'linewidth', 2);

hold on

for p10val = p10
    plot([p10val, p10val], [0.0, 0.1], 'r:', 'linewidth', 2)
end

for p90val = p90
    plot([p90val, p90val], [0.0, 0.9], 'g:', 'linewidth', 2)
end

title(['Membership function for objective ' num2str(iObj)])

end