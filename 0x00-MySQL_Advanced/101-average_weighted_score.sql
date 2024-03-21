-- Create stored procedure to compute and store the average weighted score for all students
DELIMITER //

CREATE PROCEDURE ComputeAverageWeightedScoreForUsers()
BEGIN
    -- Declare variables for calculation
    DECLARE user_id_val INT;
    DECLARE proj_id_val INT;
    DECLARE score_val FLOAT;
    DECLARE weighted_score FLOAT;
    DECLARE total_weighted_score FLOAT;
    DECLARE total_weight FLOAT;

    -- Cursor to iterate over corrections table
    DECLARE user_proj_cursor CURSOR FOR
        SELECT user_id, project_id, score
        FROM corrections;

    -- Declare handler for not found condition
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET done = TRUE;

    -- Empty tables before computing new scores
    TRUNCATE TABLE users;

    -- Open cursor
    OPEN user_proj_cursor;

    -- Loop through each record in corrections table
    read_loop: LOOP
        -- Fetch record
        FETCH user_proj_cursor INTO user_id_val, proj_id_val, score_val;

        -- Check if cursor is empty
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Calculate weighted score for the current project
        SELECT weight INTO total_weight FROM projects WHERE id = proj_id_val;
        SET weighted_score = score_val * total_weight;

        -- Update total weighted score for the user
        UPDATE users
        SET average_score = average_score + weighted_score
        WHERE id = user_id_val;

        -- Update total weight for the user
        UPDATE users
        SET total_weight = total_weight + total_weight
        WHERE id = user_id_val;
    END LOOP;

    -- Close cursor
    CLOSE user_proj_cursor;

    -- Calculate average weighted score for each user
    UPDATE users
    SET average_score = average_score / total_weight;

END //
DELIMITER ;
