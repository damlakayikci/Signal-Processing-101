
%% load Data
hdfc = readtable('HDFCBANK.csv', 'VariableNamingRule', 'preserve');
icici = readtable('ICICIBANK.csv', 'VariableNamingRule', 'preserve');
indusind = readtable('INDUSINDBK.csv', 'VariableNamingRule', 'preserve');
kotak = readtable('KOTAKBANK.csv', 'VariableNamingRule', 'preserve');

% find common fates
common_dates = intersect(intersect(intersect(hdfc.Date, icici.Date), indusind.Date), kotak.Date);

% filter by common dates
hdfc = hdfc(ismember(hdfc.Date, common_dates), :);
icici = icici(ismember(icici.Date, common_dates), :);
indusind = indusind(ismember(indusind.Date, common_dates), :);
kotak = kotak(ismember(kotak.Date, common_dates), :);
dates = datetime(hdfc.Date, 'InputFormat', 'yyyy-MM-dd');

% extract VWAP series
vwap = [hdfc.VWAP, icici.VWAP, indusind.VWAP, kotak.VWAP];
stocks = {'HDFC', 'ICICI', 'INDUSIND', 'KOTAK'};

%% Parameters
window = 20;       % SMA window
alpha = 0.2;       % EMA smoothing factor
sma = zeros(size(vwap));
ema = zeros(size(vwap));
macd = zeros(size(vwap));
signal = zeros(size(vwap));

%% Part 1: SMA and EMA
for i = 1:4
    sma(:, i) = movmean(vwap(:, i), window);           % SMA
    ema(:, i) = filter(alpha, [1, alpha - 1], vwap(:, i));  % EMA (recursive IIR)

    % MACD for Part 1.3
    short = movmean(vwap(:, i), 12);
    long = movmean(vwap(:, i), 26);
    macd(:, i) = short - long;
    signal(:, i) = movmean(macd(:, i), 9);  % MACD signal line
end

%% Plot for Last 1000 Days
% Plot and export each bank's figure separately for high-res vertical layout
bank_names = {'HDFC', 'ICICI', 'INDUSIND', 'KOTAK'};

for i = 1:4
    f = figure('Visible', 'off');  % Hide figure while saving (optional)
    idx = length(vwap(:,i)) - 999 : length(vwap(:,i));

    plot(dates(idx), vwap(idx,i), 'b'); hold on;
    plot(dates(idx), sma(idx,i), 'r');
    plot(dates(idx), ema(idx,i), 'g');

    title(sprintf('%s - Last 1000 Days', bank_names{i}));
    xlabel('Date');
    ylabel('VWAP');
    legend('Original', 'SMA', 'EMA');
    grid on;

    % Export as high-res PNG
    filename = sprintf('%s_sma_ema_plot.png', lower(bank_names{i}));
    exportgraphics(f, filename, 'Resolution', 300);
    close(f);  % Close figure after saving
end

%% Part 1.3: MACD Plot
% MACD (Moving Average Convergence Divergence)
figure;
% Save individual MACD plots for each bank
% Combined plot: VWAP (left axis), MACD & Signal Line (right axis)
for i = 1:4
    f = figure('Visible', 'off');
    idx = length(vwap(:,i)) - 999:length(vwap(:,i));
    
    yyaxis left
    plot(dates(idx), vwap(idx,i), 'b');
    ylabel('VWAP');
    
    yyaxis right
    plot(dates(idx), macd(idx,i), 'k'); hold on;
    plot(dates(idx), signal(idx,i), 'm');
    ylabel('MACD Value');

    title([stocks{i} ' VWAP + MACD - Last 1000 Days']);
    legend('VWAP', 'MACD', 'Signal Line');
    xlabel('Date');
    grid on;
    
    filename = sprintf('%s_combined_macd_plot.png', lower(stocks{i}));
    exportgraphics(f, filename, 'Resolution', 300);
    close(f);
end

%% Part 2: Trading Simulation
initial_money = 10000;
money = initial_money * ones(1, 4);
shares = zeros(1, 4);
logfile = fopen('trading_log.txt', 'w');
last600_idx = length(vwap(:,1))-599:length(vwap(:,1)); % last 600 days

for t = last600_idx  % Loop through the last 600 trading days
    for i = 1:4  % Loop through each of the 4 bank stocks

        price = vwap(t, i);      % Current price (VWAP) of the stock
        m = macd(t, i);          % MACD value for the current day
        s = signal(t, i);        % Signal line value for the current day

        if m > s  % BUY signal: MACD is above signal line
            amount_to_invest = 0.1 * money(i);  % Invest 10% of available cash
            shares(i) = shares(i) + amount_to_invest / price;  % Buy shares
            money(i) = money(i) - amount_to_invest;  % Update remaining cash
            fprintf(logfile, 'Day %d: BUY %.2f currency of %s\n', ...
                    t, amount_to_invest, stocks{i});

        elseif m < s && shares(i) > 0  % SELL signal: MACD is below signal line
            value = 0.1 * shares(i) * price;  % Sell 10% of held shares
            money(i) = money(i) + value;      % Add to available cash
            shares(i) = shares(i) - 0.1 * shares(i);  % Reduce number of shares
            fprintf(logfile, 'Day %d: SELL %.2f currency of %s\n', ...
                    t, value, stocks{i});
        end
    end
end

fclose(logfile);

% Final Worth Calculation
final_prices = vwap(last600_idx(end), :);
final_worth_per_bank = money + shares .* final_prices;

fprintf('\nFinal Net Worth Per Bank:\n');
for i = 1:4
    fprintf('%s: %.2f currency units\n', stocks{i}, final_worth_per_bank(i));
end

total_worth = sum(final_worth_per_bank);
fprintf('\nTotal Final Net Worth: %.2f (Initial: %.2f)\n', total_worth, initial_money);