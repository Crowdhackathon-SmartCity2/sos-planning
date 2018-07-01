library(readxl)
library(RPostgreSQL)
library(ggmap)
library(gdata)
library(rpostgis)
library(rgdal)
library(tbart)
library(reshape)
library(base)

studs = read_excel("students.xlsx")
#studs$address <- revgeocode(studs$xcoord,studs$ycoord)
schls = read_excel("schools.xlsx")
drv = dbDriver("PostgreSQL")
con <- dbConnect(drv, user = 'postgres', password = '1234', host = 'localhost', port = '5432', dbname = 'mjt_network')
dbWriteTable(con, "students", value = studs, row.names = FALSE)
dbWriteTable(con, "schools", value = schls, row.names = FALSE)

## find nn (vertices) from schools and students 

#simple query
data <- dbGetQuery(con, "SELECT geom from schools")
schools <- dbGetQuery(con, "select * from schools")
students <- dbGetQuery(con, "select id::integer, the_geom, students from roads_vertices_pgr where students>0")
roads <- dbGetQuery(con, "select * from roads_vertices_pgr")
verticess <- dbGetQuery(con, "select id::integer, the_geom, students from roads_vertices_pgr where students>0")
x <- dbGetQuery(con, "select*from distancematrix")

x$alloc<-0
schools$sum<-0
  
  for (i in 1:137) {
    sum<-0
    min<-10000
    min_line<-0
    for (j in 1:585) {
      if (x[j,2]==students[i,1] & min>x[j,3]) {
        
          min<-x[j,3]
          min_line<-j
          print(min)
          print(min_line)
      }
      
    }
    if (min_line != 0) {
      for (z in 1:5) {
        if (schools$sum[z]<=schools$capacity[z]) {
          if (x$start_vid[min_line]==schools$vertice[z]) {
            schools$sum[z]<- schools$sum[z] +1
          } 
        }
      } 
      
    }
    x$alloc[min_line]<-1
  }
print(sum) 
plot(x$geom)


#dat <- readOGR(dsn="PG:dbname='mjt_network',schools")

distMatrix <- readOGR(dsn="PG:dbname='mjt_network',distancematrix")
x <- pgGetGeom(con,"public","distancematrix")
#plot data from pg
plot(pgGetGeom(con,c("public","schools")))
plot(pgGetGeom(con,c("public","roads")))
plot(pgGetGeom(con,c("public","roads_vertices_pgr")),add=T)


