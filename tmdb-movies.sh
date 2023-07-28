#!/bin/bash

# Get data
wget https://raw.githubusercontent.com/yinghaoz1/tmdb-movie-dataset-analysis/master/tmdb-movies.csv

# inplace "," with "|" within a column
sed -i 's/, / | /g' tmdb-movies.csv

# stat info columns
csvstat -n tmdb-movies.csv

# Sắp xếp các bộ phim theo ngày phát hành giảm dần rồi lưu ra một file mới    
csvsort -c 16 -r tmdb-movies.csv > sorted_released_movies.csv

# Lọc ra các bộ phim có đánh giá trung bình trên 7.5 rồi lưu ra một file mới
csvsql --query "SELECT * FROM file WHERE CAST(vote_average AS FLOAT) > 7.5" --tables file --no-inference tmdb-movies.csv > high_rated_movies.csv

# Tìm ra phim nào có doanh thu cao nhất và doanh thu thấp nhất
csvcut -c 6,21 tmdb-movies.csv | sort -n -r -t "," -k 2 | head -n 15

csvcut -c 6,21 tmdb-movies.csv | sort -n -r -t "," -k 2 | tail -n 15

# Tính tổng doanh thu tất cả các bộ phim
csvcut -c 21 tmdb-movies.csv | awk '{ sum += $1 } END { printf "Total Revenue_adj: %s\n", sum }'

# Top 10 bộ phim đem về lợi nhuận cao nhất
cut -d ',' -f 4,6,21 tmdb-movies.csv | awk -F ',' '{ profit = $3 - $1; print $2, profit }' | sort -n -k 2 -r | head -n 10

# Đạo diễn nào có nhiều bộ phim nhất và diễn viên nào đóng nhiều phim nhất
csvcut -d ',' -c 7 tmdb-movies.csv | tr '|' '\n' | sort | uniq -c | sort -nr | head -n 1
csvcut -d ',' -c 9 tmdb-movies.csv | sort | uniq -c | sort -nr | head -n 1

# Thống kê số lượng phim theo các thể loại. Ví dụ có bao nhiêu phim thuộc thể loại Action, bao nhiêu thuộc thể loại Family,
csvcut -d ',' -c 14 tmdb-movies.csv | tr '|' '\n' | sort | uniq -c | sort -nr


echo "Process data is completed"
