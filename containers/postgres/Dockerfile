FROM postgres:9.6.1

USER postgres

#RUN /etc/init.d/postgresql start &&\
#    psql --command "CREATE USER PlanIt WITH SUPERUSER PASSWORD 'PlanIt';" &&\
#    createdb -O PlanIt PlanIt

# allow remote connections
#RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
#RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

#EXPOSE 5432

# NOTE: a volume to persist the database is already declared in base image
# NOTE: a default command is also included in base image
