CREATE TABLE IF NOT EXISTS taxonomy (
    id INT PRIMARY KEY AUTO_INCREMENT,
    iterm VARCHAR(255) UNIQUE,
    domain VARCHAR(100),
    subject VARCHAR(100),
    facet VARCHAR(100), 
    lword VARCHAR(255),
    INDEX (domain),
    INDEX (subject),
    INDEX (facet),
    INDEX (lword)
);
